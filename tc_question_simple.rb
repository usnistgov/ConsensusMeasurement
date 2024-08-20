#!/usr/bin/env ruby
# Tests of question_simple

require_relative 'ConsensusMeasurement'
require 'test/unit'

class TestQuestionSimple < Test::Unit::TestCase

  def test_normal
    assert_equal(
      ConsensusMeasurement.question_simple(10, 66, 33, Rational(2,3)),
      :accepted)
    assert_equal(
      ConsensusMeasurement.question_simple(10, 33, 66, Rational(2,3)),
      :rejected)
    assert_equal(
      ConsensusMeasurement.question_simple(10, 66, 34, Rational(2,3)),
      :negative_result)
    assert_equal(
      ConsensusMeasurement.question_simple(10, 6, 3, Rational(2,3)),
      :null_result)
  end

  def test_wrong_type
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(1.0, 6, 3, Rational(2,3)) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(10, 6.0, 3, Rational(2,3)) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(10, 6, 3.0, Rational(2,3)) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(10, 6, 3, 2.0/3) }
  end

  def test_too_small
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(0, 6, 3, Rational(2,3)) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(10, -1, 3, Rational(2,3)) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(10, 6, -1, Rational(2,3)) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(10, 6, 3, Rational(1,2)) }
  end

  def test_too_big
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question_simple(10, 6, 3, Rational(11,10)) }
  end

end
