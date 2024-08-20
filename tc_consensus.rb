#!/usr/bin/env ruby
# Tests of consensus?

require_relative 'ConsensusMeasurement'
require 'test/unit'

class TestConsensus < Test::Unit::TestCase

  def test_true
    assert( ConsensusMeasurement.consensus?(
              6, 10, :majority) )
    assert( ConsensusMeasurement.consensus?(
              6, 10, :supermajority, Rational(3,5)) )
    assert( ConsensusMeasurement.consensus?(
              9, 10, :near_unanimity, 1) )
    assert( ConsensusMeasurement.consensus?(
              10, 10, :unanimity) )
  end

  def test_false
    assert( !ConsensusMeasurement.consensus?(
              5, 10, :majority) )
    assert( !ConsensusMeasurement.consensus?(
              6, 10, :supermajority, Rational(2,3)) )
    assert( !ConsensusMeasurement.consensus?(
              8, 10, :near_unanimity, 1) )
    assert( !ConsensusMeasurement.consensus?(
              9, 10, :unanimity) )
  end

  def test_wrong_type
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6.0, 10, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 10.0, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 10, 0) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 10, :supermajority, 2.0/3) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 10, :near_unanimity, 1.0) }
  end

  def test_too_small
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(-1, 10, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 5, :majority) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 10, :supermajority, Rational(1,2)) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 10, :near_unanimity, -1) }
  end

  def test_too_big
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 10, :supermajority, Rational(11,10)) }
    assert_raise( RuntimeError ) {
      ConsensusMeasurement.consensus?(6, 10, :near_unanimity, 5) }
  end

end
