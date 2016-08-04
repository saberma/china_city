require 'GB2260'
require 'json'
require 'csv'
require 'pry'
require 'china_unit'

# GB2260 还未提供 201605 民政局统计数据
GB2260::Data.data['201605'] = Hash[File.readlines('db/GB2260-201605.txt').map {|l| l.chomp.split("\t") }]
GB2260::LATEST_REVISION = '201605'

namespace :gem do

  desc 'tmp'
  task :tmp do
    binding.pry

    data = CSV.read('db/sf_not_found.csv')

    CSV.open('db/sf_not_found.csv', 'w') do |csv|
      data.each do |i|
        if i[4]=='1' and i[0]=='海南省'
          i[2] = i[1]
          i[1] = "省直辖县级行政单位" 
        end
        csv << i
      end
    end
  end

  desc '导入顺丰货到付款数据'
  task :sf_cash_on_delivery_list do
    data = CSV.read('db/sf_not_found.csv')
    not_found = []
    result = []
    all = data.size
    data.each_with_index do |v, index|
      print "#{index.to_f/all * 100}%\r"
      $stdout.flush
      begin 
        search_result = ChinaUnit.find_by_names(v[0..-2])
        fetch_name = search_result.last.full_name
        search_result.last.by_level(3)["support_sf"] = true
      rescue ChinaUnitNotFoundError => e
        not_found << e.names.push(e.level)
        next
      end
    end

    File.open('db/areas.json', 'w') do |f|
      f.write JSON.pretty_generate(ChinaUnit::DATA)
    end

    CSV.open('db/sf_not_found.csv', 'w') do |csv|
      not_found.each do |i|
        csv << i
      end
    end
  end

  desc '从民政局网站抓取并生成省市区数据'
  task :update_data_from_mca do
    ChinaUnit.each(0) do |province|
      ChinaUnit.new(province['id']).mca_data.each do |i|
        p "empty: #{i}" if i['id'].empty?
        u = ChinaUnit.new(i['id']).oneself
        if u
          u.merge! i
        else
          p "not found: #{i}"
        end
      end
      sleep(2)
    end

    File.open('db/areas.json', 'w') do |f|
      f.write JSON.pretty_generate(ChinaUnit::DATA)
    end
  end

  desc '对比顺丰覆盖数据'
  task :diff_sf_china_cover do
    # 获取顺丰覆盖数据中街道数据
    sf_china_cover = CSV.read('db/sf_china_cover.csv').select.each_with_index do |row, i|
      i!=0 and row[6] and row[7] != '未开通'
    end.map{|i| i.slice(3..6)}

    not_found = {}

    all = sf_china_cover.size

    # 逐个对比
    sf_china_cover.each_with_index do |names, index|
      begin
        full_name = names.join('')
        search_result = ChinaUnit.find_by_names(names)
        fetch_name = search_result.last.full_name
        if full_name == fetch_name
          search_result.last.by_level(3)["support_sf"] = true
          print "#{index.to_f/all * 100}%\r"
          $stdout.flush
        else
          search_result.last.by_level(3)["support_sf"] = true
          p "#{full_name} => #{fetch_name} #{index.to_f/all * 100}%"
        end
      rescue ChinaUnitNotFoundError => e
        not_found[e.names.join("")] = {
          names: e.names, name: e.name,
          parents: e.parents.map{|i| i.id},
          level: e.level
        }
      end
    end

    puts
    puts "not_found: #{not_found.keys.size}"

    File.open('db/areas.json', 'w') do |f|
      f.write JSON.pretty_generate(ChinaUnit::DATA)
    end

    File.open('db/sf_not_found.json', 'w') do |f|
      f.write JSON.pretty_generate(not_found)
    end
  end

  desc '更新 areas.json 数据'
  task :update_data do
    # 1. 获取淘宝所有的街道
    gb2260 = GB2260.new

    provinces = []
    cities    = []
    districts = []
    streets   = []

    gb2260.provinces.each do |province|                                                 # 省
      gb_cities = gb2260.prefectures(province.code)
      gb_cities.each do |city|                                                          # 市
        cities << { text:city.name, id: city.code }
        gb_districts = gb2260.counties(city.code)
        gb_districts << GB2260::Division.new("#{city.code[0,4]}99", city.name) if gb_districts.empty?    # 中山市等没有县级，需要自动补上
        gb_districts.each do |district|                                                 # 区
          districts << { text: district.name, id: district.code }
        end
      end

      # 台湾省、香港、澳门没有市
      if gb_cities.empty? && ["710000", "810000", "820000"].include?(province.code)
        provinces << { text:province.name, id: province.code, sensitive_areas: true } 
      else
        provinces << { text:province.name, id: province.code } 
      end
    end

    map_codes = YAML.load_file("db/district_gb2260_taobao.yml")
    districts.each do |district|
      code = district[:id]
      result = get_remote_streets(map_codes[code] || code)
      result = [{text: "全境", id: "#{code}001"}] unless result
      result.each do |tstreet|                                                          # 街道
        street_code = "#{code}#{tstreet[:id][-3,3]}"                                    # 保证编码与区一致
        streets << {text: tstreet[:text], id: street_code}
      end
    end

    content = JSON.pretty_generate(province: provinces, city: cities, district: districts, street: streets)

    path = File.join("db/areas.json")
    File.write(path, content)
  end

  desc "显示国标与淘宝区划代码不匹配的记录."
  task :list_mismatch_districts do
    gb2260 = GB2260.new
    map_codes = YAML.load_file("db/district_gb2260_taobao.yml")
    map_codes.each do |key, value|
      division = gb2260.get(key)
      puts [division.province, division.prefecture, division.county].compact.map(&:name).join('/')
    end
  end

  desc "获取淘宝街道信息."
  task :list_streets, [:code] do |t, args|
    code = args.code
    puts get_streets code
  end

  desc '处理淘宝区代码与国标不一致的情况，将对应关系保存到 db/district_gb2260_taobao'
  task :save_district_gb2260_taobao_map do
    gb2260 = GB2260.new
    districts = []
    empty_districts = []

    # 1. 汇总所有区记录
    gb2260.provinces.each do |province|
      gb2260.prefectures(province.code).each do |city|
        data = gb2260.counties(city.code)
        GB2260::Division.new("#{city.code[0,4]}99", city.name) if data.empty?    # 中山市没有县级，需要自动补上
        data.each do |district|
          districts << district
        end
      end
    end

    # 2. 获取街道记录
    # districts.select{|district| district.code.start_with?('1301')}.each do |district|
    districts.each do |district|
      result = get_remote_streets(district.code)
      empty_districts << district unless result
    end

    # 3. 获取淘宝省市区记录
    response = HTTParty.get("https://g.alicdn.com/kg/??address/6.0.4/index-min.js?t=1449112049369.js")
    tdata = response.to_s.sub(/.+return\st=e\}\(\),r=function\(t\)\{var\se=/, '')
    tdata = tdata.sub(/;\nreturn\st=e\}\(\),c=function\(t\).+/m, '')
    cities = JSON.parse(tdata)
    result = {}
    cities.each do |city|
      result[city[1][0]] = city[0]
    end

    # 4. 输出结果
    map_data = {}
    empty_districts.each do |district|
      code = district.code
      text = district.name
      next if %w(市辖区 城区 郊区).include?(text)
      text = text.gsub(/(自治县|市|区|县)$/,'')
      text = text.gsub(/(黎族苗族|黎族苗族|侗族|土家族苗族|彝族回族苗族|土家族|苗族|回族土族|土族|回族|撒拉族)$/,'')
      text = '和县' if text == '和'
      if tid = result[text]
        map_data[code] = tid
      else
        puts text
      end
    end

    path = "db/district_gb2260_taobao.yml"
    File.write(path, map_data.to_yaml)
  end

  private
  def get_streets(code)
    map_codes = YAML.load_file("db/district_gb2260_taobao.yml")
    get_remote_streets(map_codes[code] || code)
  end

  def get_remote_streets(code)
    l1 = code[0..1].ljust(6,'0')
    l2 = code[0..3].ljust(6,'0')
    l3 = code
    l3 = l2 if l3.end_with?('99')    # 特殊处理：县级如果以99结尾，则需要取市级
    puts "fetching: #{l3}"
    response = HTTParty.get("https://lsp.wuliu.taobao.com/locationservice/addr/output_address_town_array.do?l1=#{l1}&l2=#{l2}&l3=#{l3}&lang=zh-S&_ksTS=1440400908112_7583")
    if response.size > 40
      ret = response[33..-5].split(',').map{|i| i.gsub(/[\[|\]|\"|\']+/,'')}.each_slice(4).to_a
      ret.map{|i| {text:i[1], id:i[0]}}
    end
  end

end
