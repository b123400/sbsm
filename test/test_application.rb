#!/usr/bin/env ruby
# encoding: utf-8
$: << File.dirname(__FILE__)
$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

ENV['RACK_ENV'] = 'test'
ENV['REQUEST_METHOD'] = 'GET'

require 'minitest/autorun'
require 'rack/test'
require 'sbsm/app'
require 'simple_sbsm'
require 'nokogiri'
begin
  require 'pry'
rescue LoadError
end

class MyTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    SBSM.info msg = "Starting #{SERVER_URI}"
    DRb.start_service(SERVER_URI, Demo::SimpleSBSM.new)
    sleep(0.1)
  end
  def teardown
    DRb.stop_service
  end
  def app
    Demo::SimpleSBSM.new
  end
  def test_post_feedback
    get '/de/page' do # needed to set cookie
        last_response.set_cookie SBSM::App::PERSISTENT_COOKIE_NAME, :value => "demo_cookie"
    end
    get '/de/page/feedback' do
        last_response.set_cookie SBSM::App::PERSISTENT_COOKIE_NAME, :value => "second_cookie"
    end
    assert last_response.ok?
    assert_match FEEDBACK_HTML_CONTENT, last_response.body
    page = Nokogiri::HTML(last_response.body)
    x = page.css('div')
    skip 'We must add here an input form or we cannot continue testing'

    assert  page.css('input').find{|x| x.attributes['name'].value.eql?('state_id') }.attributes['value'].value
    state_id = page.css('input').find{|x| x.attributes['name'].value.eql?('state_id') }.attributes['value'].value.to_i
    assert state_id > 0
    post '/de/page/feedback', { 'anrede' => 'Herr', 'msg' => 'SBSM rocks!' , 'state_id' => '1245'}
    assert last_response.ok?
    assert last_response.headers['Content-Length'].to_s.length > 0
    assert_match CONFIRM_HTML_CONTENT, last_response.body
    post '/de/page/feedback', { 'confirm' => 'true', 'anrede' => 'Herr', 'msg' => 'SBSM rocks!' }
    assert last_response.ok?
    assert_match CONFIRM_DONE_HTML_CONTENT, last_response.body
  end
  if false
  def test_session_home
    get '/home'
    assert last_response.ok?
    assert_match /^request_path is \/home$/, last_response.body
    assert_match HOME_HTML_CONTENT, last_response.body
    assert_match /utf-8/i, last_response.headers['Content-Type']
  end
  def test_css_file
    css_content = "html { max-width: 960px; margin: 0 auto; }"
    css_file = File.join('doc/sbsm.css')
    FileUtils.makedirs(File.dirname(css_file))
    unless File.exist?(css_file)
      File.open(css_file, 'w+') do |file|
        file.puts css_content
      end
    end
    get '/sbsm.css'
    assert last_response.ok?
    assert_match css_content, last_response.body
  end
  def test_session_about_then_home
    get '/de/page/about'
    assert last_response.ok?
    assert_match /^About SBSM: TDD ist great!/, last_response.body
    get '/home'
    assert last_response.ok?
    assert_match HOME_HTML_CONTENT, last_response.body
  end
  def test_default_content_from_home
    test_path = '/default_if_no_such_path'
    get test_path
    assert last_response.ok?
    assert_match /^#{HOME_HTML_CONTENT}/, last_response.body
    assert_match HOME_HTML_CONTENT, last_response.body
    assert_match /^request_path is /, last_response.body
    assert_match test_path, last_response.body
  end
  def test_session_id_is_maintained
    get '/'
    assert last_response.ok?
    body = last_response.body.clone
    assert_match /^request_path is \/$/, body
    assert_match /member_counter is 1$/, body
    assert_match HOME_HTML_CONTENT, body
    m = /class_counter is (\d+)$/.match(body)
    counter = m[1]
    assert_match /class_counter is (\d+)$/, body
    # Getting the request a second time must increment the class, but not the member counter
    get '/'
    assert last_response.ok?
    body = last_response.body.clone
    assert_match /^request_path is \/$/, body
    assert_match /member_counter is 1$/, body
    assert_match /class_counter is #{counter.to_i+1}$/, body
  end
  def test_session_home_then_fr_about
    get '/home'
    assert last_response.ok?
    assert_match /^request_path is \/home$/, last_response.body
    assert_match HOME_HTML_CONTENT, last_response.body
    get '/fr/page/about'
    assert last_response.ok?
    assert_match ABOUT_HTML_CONTENT, last_response.body
  end
  end
end