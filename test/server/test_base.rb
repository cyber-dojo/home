# frozen_string_literal: true
require_relative '../id58_test_base'
require_source 'app'
require_source 'externals'
require 'json'

class TestBase < Id58TestBase

  include Rack::Test::Methods # [1]

  def app # [1]
    App.new(externals)
  end

  def externals
    @externals ||= Externals.new
  end

  # - - - - - - - - - - - - - - -

  def assert_get_200_json(path, &block)
    stdout,stderr = capture_io { get '/'+path }
    assert status?(200), status
    assert json_content?, content_type
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :sdout
    block.call(json_response)
  end

  def assert_get_200_html(path)
    stdout,stderr = capture_io { get '/'+path }
    assert status?(200), status
    assert html_content?, content_type
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :sdout
  end

  def assert_get_500_json(path, &block)
    stdout,stderr = capture_io { get '/'+path }
    assert status?(500), status
    assert json_content?, content_type
    assert_equal '', stderr, :stderr
    assert_equal stdout, last_response.body+"\n", :stdout
    block.call(json_response)
  end

  def assert_post_200_json(path, args, &block)
    stdout,stderr = capture_io { json_post '/'+path, args }
    assert status?(200), status
    assert json_content?, content_type
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
    block.call(json_response)
  end

  # - - - - - - - - - - - - - - -

  def status?(code)
    status === code
  end

  def status
    last_response.status
  end

  # - - - - - - - - - - - - - - -

  def html_content?
    content_type === 'text/html;charset=utf-8'
  end

  def css_content?
    content_type === 'text/css; charset=utf-8'
  end

  def json_content?
    content_type === 'application/json'
  end

  def js_content?
    content_type === 'application/javascript'
  end

  def content_type
    last_response.headers['Content-Type']
  end

  # - - - - - - - - - - - - - - -

  def json_post(path, data)
    post path, data.to_json, JSON_REQUEST_HEADERS
  end

  def json_response
    JSON.parse(last_response.body)
  end

  JSON_REQUEST_HEADERS = {
    'CONTENT_TYPE' => 'application/json', # sent request
    'HTTP_ACCEPT' => 'application/json'   # received response
  }

  # - - - - - - - - - - - - - - -

  def kata_exists?(id)
    model.kata_exists?(id)
  end

  def model
    @externals.model
  end

end
