#!/usr/bin/env ruby
# Tests of one_of_m

require_relative 'ConsensusMeasurement'
require 'test/unit'

class Test1ofM < Test::Unit::TestCase

  def test_normal
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [5, 4], 9, :majority),
      0)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [6, 3], 9, :supermajority, Rational(2,3)),
      0)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [6, 0], 6, :unanimity),
      0)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [4, 5], 9, :majority),
      1)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [1, 9], 10, :near_unanimity, 1),
      1)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [6, 3], 9, :supermajority, Rational(3,4)),
      :negative_result)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [5, 5], 10, :majority),
      :negative_result)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_voting, 10, 10,
                                    [5, 4], 9, :majority),
      :null_result)
    assert_equal(
      ConsensusMeasurement.one_of_m(:proportion_voting, Rational(1,5), 10,
                                    [0, 0], 10, :majority),
      :null_result)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 0,
                                    [0, 0], 0, :majority),
      :null_result)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [10], 10, :unanimity),
      0)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_voting, 1, 10,
                                    [1, 2, 3, 4], 10, :majority),
      :negative_result)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_voting, 1, 10,
                                    [0, 1, 3, 5], 9, :majority),
      3)
    assert_equal(
      ConsensusMeasurement.one_of_m(:num_voting, 1, 10,
                                    [0, 5, 3, 1], 9, :majority),
      1)
  end

  def test_wrong_type
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [5.0, 4], 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [5, 4.0], 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    nil, 9, :majority) }
  end

  def test_too_small
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [-1, 4], 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [5, -1], 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [], 9, :majority) }
  end

  def test_too_big
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 8,
                                    [5, 4], 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [5, 4], 8, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_present, 1, 10,
                                    [5, 5], 9, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.one_of_m(:num_voting, 1, 10,
                                    [9, 8, 9, 9], 9, :unanimity) }
  end

end
