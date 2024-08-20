#!/usr/bin/env ruby
# Tests of question

require_relative 'ConsensusMeasurement'
require 'test/unit'

class TestQuestion < Test::Unit::TestCase

  def test_normal
    assert_equal(
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    5, 4, 9, :majority),
      :accepted)
    assert_equal(
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    6, 3, 9, :supermajority, Rational(2,3)),
      :accepted)
    assert_equal(
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    6, 0, 6, :unanimity),
      :accepted)
    assert_equal(
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    4, 5, 9, :majority),
      :rejected)
    assert_equal(
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    1, 9, 10, :near_unanimity, 1),
      :rejected)
    assert_equal(
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    6, 3, 9, :supermajority, Rational(3,4)),
      :negative_result)
    assert_equal(
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    5, 5, 10, :majority),
      :negative_result)
    assert_equal(
      ConsensusMeasurement.question(:num_voting, 10, 10,
                                    5, 4, 9, :majority),
      :null_result)
    assert_equal(
      ConsensusMeasurement.question(:proportion_voting, Rational(1,5), 10,
                                    0, 0, 10, :majority),
      :null_result)
    assert_equal(
      ConsensusMeasurement.question(:num_present, 1, 0,
                                    0, 0, 0, :majority),
      :null_result)
  end

  def test_wrong_type
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    5.0, 4, 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    5, 4.0, 9, :majority) }
  end

  def test_too_small
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    -1, 4, 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    5, -1, 9, :majority) }
  end

  def test_too_big
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question(:num_present, 1, 8,
                                    5, 4, 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.question(:num_present, 1, 10,
                                    5, 4, 8, :majority) }
  end

end
