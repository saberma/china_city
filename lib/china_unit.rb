require 'nokogiri'
class ChinaUnit
  include HTTParty

  # 民政局的国家数据查询平台
  base_uri 'http://202.108.98.30/'
  #debug_output $stdout

  DATA = JSON.parse(File.read("db/areas.json"))
  LEVELS = DATA.keys
  NOT_FOUND = []

  attr_accessor :id, :text

  def initialize(id)
    self.id = id
    self.text = self.parents.last['text']
  end

  def mca_data
    query = {
      shengji:  "#{self.parents[0]['text']}(#{self.parents[0]["short"].join("、")})".encode(Encoding::GBK),
      diji: self.parents[1] ? self.parents[1]['text'].encode(Encoding::GBK) : -1,
      xianji: self.parents[2] ? self.parents[2]['text'].encode(Encoding::GBK) : -1,
    }
    html = self.class.get('/defaultQuery', {query: query})
    document = Nokogiri::HTML(html)
    header = %w(text station population area id areacode postcode)
    body =  document.css('table.info_table tr').each_with_index.map do |tr, index|
      Hash[header.zip(tr.css('td').map{|i| i.text.gsub('+', '').strip})]
    end.reject{|i| !i['id'] or i['id'].empty?}
    body
  end

  def level
    @level ||= if self.id.size > 6
                 3
               else
                 2 - self.id.scan(/\d{2}/).select{|i|i=='00'}.size
               end
  end

  def id_by_level(level)
    if level < 3
      id.slice(0..(level*2+1)).ljust(6, '0')
    else
      id
    end
  end

  def by_level(level)
    DATA[LEVELS[level]].find{|i| i['id'] == id_by_level(level)}
  end

  def parents
    @parents ||= (0..level).map{|l| by_level(l)}.compact.uniq
  end

  def oneself
    @oneself ||= DATA[LEVELS[level]].find{|i| i['id'] == id}
  end

  def children
    @children ||= if level < 3
                    DATA[LEVELS[level+1]].select{|i| i['id'].start_with? id.gsub('00', '')}
                  else
                    nil
                  end
  end

  def full_name 
    parents.map{|i| i['text']}.join('')
  end

  def self.find_by_names(names)
    names.each_with_index.inject([]) do |r, (name, index)|
      r << find_by_name(name, index, r, names)
      r
    end
  end

  def self.select_text(result)
    result.each_with_index.map{|i,index| index.to_s + '.' + ChinaUnit.new(i['id']).full_name}.join("   ")
  end

  def self.find_by_name(name, level, parents = [], names)
    data = if parents.empty? 
              DATA[LEVELS[level]]
            else
              parents.last.children
            end
    result, similar_val = similar(name, data)
    target = nil
    if result.size == 1
      target = ChinaUnit.new result.first['id']
    else
      selected, options = get_selected_and_options_from_STDIN(names, result, data)
      target = selected ? ChinaUnit.new(options[selected.to_i]['id']) : nil
    end
    return target
  end

  def self.get_selected_and_options_from_STDIN(names, group1, group2)
    selected = nil
    options = group1
    p '----------------------'
    p "#{names.join('')} 是指:"
    p select_text(group1)
    p "请输入序号选择, 没有请按e放大搜索范围，或者按n跳过: "
    loop do
      selected = STDIN.gets.strip
      case selected
      when 'i'
        binding.pry
        exit
      when 'e'
        options = group2
        p select_text(group2)
        p "请输入序号选择, 按n跳过: "
      when 'n'
        NOT_FOUND << [names, result]
        break
      else
        break
      end
    end
    return selected, options
  end

  # 简单匹配文本相似度最高的
  # 从 arr 中选出和 key 最为相似的项
  def self.similar(key, arr)
    key_chars = key.split("")
    results = arr.inject({}) do |r, i|
      a = i['text'].split("") 
      b = key_chars
      # 文本 a 和 b 的相似度 = a 和 b 的字符交集 / a 和 b 的字符并集
      similar_val = i['text'] == key ? 1 : (a & b).size.to_f/(a | b).size
      (r[similar_val] ||= []) << i
      r
    end
    max = results.keys.max
    return results[max], max
  end

  def self.each(level, &block)
    DATA[LEVELS[level]].each(&block)
  end

end
