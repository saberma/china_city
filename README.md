# ChinaCity 省市区级联选择

[![Build Status](https://travis-ci.org/saberma/china_city.png?branch=master)](https://travis-ci.org/saberma/china_city)

![china_city](http://cl.ly/image/3c212i1e3b1T/ScreenFlow.mp4.gif)

支持 Rails3.1, Rails3.2, Rails4.0。

请留意，Rails3.1 与 Ruby2.0 不兼容，sprockets 无法正常解析 application.js，请使用 Ruby1.9。

## 简介

这是一个基于 Rails Engine 开发的插件，为 Rails 项目增加省市区三级（或者省市 二级）选择框，可用于实现收货地址等信息的录入。

## 安装

### Gemfile

    gem 'china_city'

### app/assets/javascripts/application.js

    //= require 'jquery'
    //= require 'china_city/jquery.china_city'

### config/routes.rb

    mount ChinaCity::Engine => '/china_city'

## 使用

在页面中加入选择框，示例代码使用 slim 格式

```ruby
  .city-group
    select.state
      option --省份/洲--
      = options_for_select(ChinaCity.html_options)
    select.city
      option --城市--
    select.district
      option --地区--
```

```ruby
$('.china-city').china_city()

# 也可以用自己的选择器来选择各自的select
$('.china-city').china_city({state: '.state', city: '.city', district: '.district'})
```

选择后的值为国家名

## 贡献

```bash
git clone git@github.com:saberma/china_city.git
cd china_city
rake appraisal:install
cd spec/dummy
rails server # http://localhost:3000/china_city
```

## 测试

```bash
rvm use 2.0.0
rake appraisal:rails4 spec
rake appraisal:rails32 spec
rvm use 1.9.3
bundle install
rake appraisal:rails31 spec
```

## 类似项目

* https://github.com/Kehao/area_cn_select
