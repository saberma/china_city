# encoding: utf-8
require 'spec_helper'

describe ChinaCity do
  it 'should be list' do
    # 省
    ChinaCity.list.should eql [["北京市", "110000"], ["天津市", "120000"], ["河北省", "130000"], ["山西省", "140000"], ["内蒙古自治区", "150000"], ["辽宁省", "210000"], ["吉林省", "220000"], ["黑龙江省", "230000"], ["上海市", "310000"], ["江苏省", "320000"], ["浙江省", "330000"], ["安徽省", "340000"], ["福建省", "350000"], ["江西省", "360000"], ["山东省", "370000"], ["河南省", "410000"], ["湖北省", "420000"], ["湖南省", "430000"], ["广东省", "440000"], ["广西壮族自治区", "450000"], ["海南省", "460000"], ["重庆市", "500000"], ["四川省", "510000"], ["贵州省", "520000"], ["云南省", "530000"], ["西藏自治区", "540000"], ["陕西省", "610000"], ["甘肃省", "620000"], ["青海省", "630000"], ["宁夏回族自治区", "640000"], ["新疆维吾尔自治区", "650000"]]

    ChinaCity.list(nil, show_all: true).should eql [["北京市", "110000"], ["天津市", "120000"], ["河北省", "130000"], ["山西省", "140000"], ["内蒙古自治区", "150000"], ["辽宁省", "210000"], ["吉林省", "220000"], ["黑龙江省", "230000"], ["上海市", "310000"], ["江苏省", "320000"], ["浙江省", "330000"], ["安徽省", "340000"], ["福建省", "350000"], ["江西省", "360000"], ["山东省", "370000"], ["河南省", "410000"], ["湖北省", "420000"], ["湖南省", "430000"], ["广东省", "440000"], ["广西壮族自治区", "450000"], ["海南省", "460000"], ["重庆市", "500000"], ["四川省", "510000"], ["贵州省", "520000"], ["云南省", "530000"], ["西藏自治区", "540000"], ["陕西省", "610000"], ["甘肃省", "620000"], ["青海省", "630000"], ["宁夏回族自治区", "640000"], ["新疆维吾尔自治区", "650000"], ["台湾省", "710000"], ["香港特别行政区", "810000"], ["澳门特别行政区", "820000"]]

    #市
    ChinaCity.list('440000').should eql [["广州市", "440100"], ["韶关市", "440200"], ["深圳市", "440300"], ["珠海市", "440400"], ["汕头市", "440500"], ["佛山市", "440600"], ["江门市", "440700"], ["湛江市", "440800"], ["茂名市", "440900"], ["肇庆市", "441200"], ["惠州市", "441300"], ["梅州市", "441400"], ["汕尾市", "441500"], ["河源市", "441600"], ["阳江市", "441700"], ["清远市", "441800"], ["东莞市", "441900"], ["中山市", "442000"], ["潮州市", "445100"], ["揭阳市", "445200"], ["云浮市", "445300"]]

    #区
    ChinaCity.list('440300').should eql [["罗湖区", "440303"], ["福田区", "440304"], ["南山区", "440305"], ["宝安区", "440306"], ["龙岗区", "440307"], ["盐田区", "440308"]]

    #街道
    ChinaCity.list('440305').should eql [["南头街道", "440305001"], ["南山街道", "440305002"], ["沙河街道", "440305003"], ["蛇口街道", "440305005"], ["招商街道", "440305006"], ["粤海街道", "440305007"], ["桃源街道", "440305008"], ["西丽街道", "440305009"]]
  end

  it 'should be get' do
    ChinaCity.get('440000').should eql '广东省'
    ChinaCity.get('440300').should eql '深圳市'
    ChinaCity.get('440305').should eql '南山区'
    ChinaCity.get('440000'   , prepend_parent: true).should eql '广东省'
    ChinaCity.get('440300'   , prepend_parent: true).should eql '广东省深圳市'
    ChinaCity.get('440305'   , prepend_parent: true).should eql '广东省深圳市南山区'
    ChinaCity.get('440305001', prepend_parent: true).should eql '广东省深圳市南山区南头街道'
  end

  it 'should be parse' do # 可以直接获取省、市
    ChinaCity.province('440000').should eql '440000' # 省
    ChinaCity.city('440000').should eql '440000'
    ChinaCity.district('440000').should eql '440000'
    ChinaCity.province('440300').should eql '440000' # 市
    ChinaCity.city('440300').should eql '440300'
    ChinaCity.district('440300').should eql '440300'
    ChinaCity.province('440305').should eql '440000' # 区
    ChinaCity.city('440305').should eql '440300'
    ChinaCity.district('440305').should eql '440305'
  end

  it 'should has children' do    # 省市区都有子记录
    data = ChinaCity.data

    # 省
    empty_provinces = data.select{|k, v| v[:children].empty?}
    # empty_provinces.should be_empty
    # 港澳台暂时没有子记录
    empty_provinces.keys.should eql ["710000", "810000", "820000"]

    # 市
    cities = {}
    data.each {|k, v| v[:children].each{|ck, cv| cities[ck] = cv}}
    empty_cities = cities.select{|k, v| v[:children].empty?}
    empty_cities.should be_empty

    # 区
    districts = {}
    cities.each {|k, v| v[:children].each{|ck, cv| districts[ck] = cv}}
    empty_districts = districts.select{|k, v| v[:children].nil?}
    empty_districts.should be_empty
  end
end
