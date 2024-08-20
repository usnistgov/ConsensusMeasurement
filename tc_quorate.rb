#!/usr/bin/env ruby
# Tests of quorate?

require_relative 'ConsensusMeasurement'
require 'test/unit'

class TestQuorate < Test::Unit::TestCase

  def test_true
    assert(
      ConsensusMeasurement.quorate?(:num_present, 33, 33, 1) )
    assert(
      ConsensusMeasurement.quorate?(:num_voting, 66, 99, 66) )
    assert(
      ConsensusMeasurement.quorate?(:proportion_voting, Rational(1,3), 99, 33)
    )
  end

  def test_false
    assert(
      !ConsensusMeasurement.quorate?(:num_present, 33, 32, 32) )
    assert(
      !ConsensusMeasurement.quorate?(:num_voting, 33, 33, 32) )
    assert(
      !ConsensusMeasurement.quorate?(:num_present, 33, 33, 0) )
    assert(
      !ConsensusMeasurement.quorate?(:proportion_voting, Rational(1,3), 100, 33)
    )
  end

  def test_wrong_type
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(0, 33, 33, 1) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(:num_present, 33.0, 33, 1) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(:num_present, 33, 33.0, 1) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(:num_present, 33, 33, 1.0) }
  end

  def test_too_small
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(:num_present, 0, 33, 0) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(:num_present, 33, -1, 0) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(:num_present, 33, 33, -1) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(:num_present, 33, -1, -1) }
  end

  def test_too_big
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.quorate?(:num_present, 33, 33, 34) }
  end

end
