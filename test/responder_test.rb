require_relative './test_helper'
require './lib/responder'

class ResponderTest < Minitest::Test

  def setup
    @responder  = Responder.new
  end

  def test_hello_response
    expected = 'Hello World (0)'

    assert_equal expected, @responder.hello
  end

  def test_diagnostics
    mock = ["GET / HTTP/1.1",
            "User-Agent: Faraday v0.14.0",
            "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Accept: */*",
            "Connection: close",
            "Host: localhost:9292",
            "GET / HTTP/1.1"]

    expected = <<~HEREDOC
                Verb: GET
                Path: /
                Protocol: HTTP/1.1
                Host: localhost:9292
                Port: 9292
                Origin: localhost
                Accept: */*
               HEREDOC

    controller = Controller.new(@responder, mock)

    assert_equal expected, controller.route(mock)
  end

  def test_date_time
    expected = Time.new.strftime('%l:%M on %A, %m %e, %Y')

    assert_equal expected, @responder.date_time
  end

  def test_shut_down
    expected = 'Total Requests:'

    assert @responder.shut_down.include?(expected)
  end

  def test_word_search
    mock_1 = ["GET /word_search?word=spizzerinctum HTTP/1.1",
            "User-Agent: Faraday v0.14.0",
            "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Accept: */*",
            "Connection: close",
            "Host: localhost:9292",
            "GET / HTTP/1.1"]

    mock_2 = ["GET /word_search?word=farquad HTTP/1.1",
              "User-Agent: Faraday v0.14.0",
              "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "Accept: */*",
              "Connection: close",
              "Host: localhost:9292",
              "GET / HTTP/1.1"]

    controller_1 = Controller.new(@responder, mock_1)
    controller_1.parse

    assert_equal 'SPIZZERINCTUM is a known word', controller_1.route(mock_1)
    
    controller_2 = Controller.new(@responder, mock_2)
    controller_2.parse

    assert_equal 'FARQUAD is not a known word', controller_2.route(mock_2)
  end

  def test_game_start
    assert_equal ['Good luck!', :moved], @responder.start_game
  end

  def test_web_game
    @responder.game = Game.new
    body = <<~HEREDOC
              Guess: #{@responder.game.recent_guess}
              Guess Total: #{@responder.game.guess_total}
              Feedback: #{@responder.game.feedback}
            HEREDOC
    expected = [body, :ok]

    assert_equal expected, @responder.web_game(:ok)
  end

  def test_forbidden
    assert_equal ['Forbidden', :forbidden], @responder.forbidden
  end

  def test_not_found
    assert_equal ['Page not found', :not_found], @responder.not_found
  end

  def test_internal_error
    assert_equal ['Internal Server Error', :error], @responder.internal_error
  end
end