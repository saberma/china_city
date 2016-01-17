require 'GB2260'
require 'json'

namespace :gem do

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
      provinces << { text:province.name, id: province.code } unless gb_cities.empty?    # 台湾省、香港、澳门没有市
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
