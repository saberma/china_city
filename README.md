# ChinaCity 省市区街道级联选择

[![Build Status](https://travis-ci.org/saberma/china_city.png?branch=master)](https://travis-ci.org/saberma/china_city)

![china_city](http://cl.ly/image/3c212i1e3b1T/ScreenFlow.mp4.gif)

## 简介

这是一个基于 Rails Engine 开发的插件，为 Rails 项目增加省市区街道四级（或者省市区三级、省市二级）选择框，可用于实现收货地址等信息的录入。

### 数据来源

* 省市区: http://www.stats.gov.cn/tjsj/tjbz/xzqhdm/201504/t20150415_712722.html
* 街道: 淘宝

## 安装

### Gemfile

    gem 'china_city'

### app/assets/javascripts/application.js

    //= require 'jquery'
    //= require 'china_city/jquery.china_city'

### config/routes.rb

    mount ChinaCity::Engine => '/china_city'

## 使用

可以参考 https://github.com/saberma/china_city_example 示例代码。

在页面中加入选择框，示例代码使用 slim 格式

```ruby
  .city-group
    select.city-select
      option --省份--
      = options_for_select(ChinaCity.list)
    select.city-select
      option --城市--
    select.city-select
      option --地区--
    select.city-select
      option --街道--
```

请留意：所有选择框都要有 `city-select` class，并都包含于 class='city-group' 的 DOM 元素之下。

选择后的值为国家地区编码，如深圳市的为 `440300`，可通过调用 `ChinaCity.get('440300')` 将编码转化为城市名称。

### React 用户 [react-china-city](https://github.com/GeekPark/react-china-city)
如果你使用 React 和 webpack/browserify 可以直接使用 `npm i react-china-city --save` 来进行前端接入。

## 更新

* 0.0.5  更新省市区数据到最新的国标，支持街道

## 贡献

```bash
git clone git@github.com:saberma/china_city.git
cd china_city
rake appraisal:install
cd spec/dummy
rails server
open http://localhost:3000/china_city
```

## 测试

```bash
brew install phantomjs    # http://git.io/vRJ1M
rvm use 2.1               # Fixed: NoMethodError: undefined method `using' for GB2260::Division:Class
rake appraisal:install
rake appraisal:rails4 spec
```

## 类似项目

* https://github.com/Kehao/area_cn_select
