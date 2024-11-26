# Example implementation of decision rules for consensus from the paper
# Measuring social consensus, doi:10.48550/arXiv.2411.12067

# David Flater
# National Institute of Standards and Technology, USA
# david.flater@nist.gov
# See LICENSE

# require_relative 'ConsensusMeasurement'

module ConsensusMeasurement

  version = '1.0'

  # ---------------------------------------------------------------------------
  # Symbols (used as enum values)

  desc = Hash.new

  # Return values applicable to all contest types
  desc[:negative_result] = 'Negative result.  There is evidence of' \
                           ' the absence of consensus.'
  desc[:null_result] = 'Null result.  There is an absence of evidence.'

  # Return values applicable to yes-or-no questions
  desc[:accepted] = 'A consensus exists in favor of the proposition.'
  desc[:rejected] = 'A consensus exists in opposition to the proposition.'

  # Quorums for the elaborated model
  desc[:num_present] = 'Number of members that must be present'
  desc[:num_voting] = 'Number of members that must not abstain'
  desc[:proportion_voting] = 'Proportion of members present that must not' \
                             ' abstain'

  # Consensus thresholds for the elaborated model
  desc[:majority] = 'Majority threshold'
  desc[:supermajority] = 'Supermajority threshold'
  desc[:near_unanimity] = 'Near-unanimity threshold'
  desc[:unanimity] = 'Unanimity threshold'

  # ---------------------------------------------------------------------------
  # Methods for input validation

  # Fixnum and Bignum were replaced by Integer in Ruby 2.4.
  def self.check_nn_integer(value, name)
    raise "Parameter #{name} is not an Integer" if value.class != Integer
    raise "Parameter #{name} has a negative value" if value < 0
  end

  def self.check_pos_integer(value, name)
    check_nn_integer(value, name)
    raise "Parameter #{name} is zero" if value == 0
  end

  def self.check_proportion_rational(value, name)
    raise "Parameter #{name} is not a Rational" if value.class != Rational
    raise "Parameter #{name} is <= 0" if value <= 0
    raise "Parameter #{name} is > 1" if value > 1
  end

  def self.check_supermajority_rational(value, name)
    check_proportion_rational(value, name)
    raise "Parameter #{name} is <= 1/2" if value <= Rational(1,2)
  end

  def self.check_array_of_nn_integer(value, name)
    raise "Parameter #{name} is not an Array" if value.class != Array
    raise "Parameter #{name} is a zero-length Array" if value.empty?
    value.each_with_index { |v,i| check_nn_integer(v, "#{name}[#{i}]") }
  end

  # ---------------------------------------------------------------------------
  # Simple question

  # Measurement of consensus on a yes-or-no question using a supermajority of
  # votes as the threshold
  # quorum               Integer ≥ 1
  # votes_y and votes_n  Integer ≥ 0
  # threshold            Rational 1/2 < T ≤ 1
  # Returns :negative_result, :null_result, :accepted, or :rejected.
  def self.question_simple(quorum, votes_y, votes_n, threshold)
    check_pos_integer(quorum, 'quorum')
    check_nn_integer(votes_y, 'votes_y')
    check_nn_integer(votes_n, 'votes_n')
    check_supermajority_rational(threshold, 'threshold')
    votes = votes_y + votes_n
    if votes < quorum
      :null_result
    else
      p = Rational(votes_y, votes)
      if p >= threshold
        :accepted
      elsif p <= 1 - threshold
        :rejected
      else
        :negative_result
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Elaborated model

=begin
  Notes relevant to all of the methods that follow below

  The paper Measuring social consensus, doi:10.48550/arXiv.2411.12067,
  identifies four ways of setting the effective population size:
  P(1)  The nominal size of the voting body
  P(2)  The current size of the voting body with vacant positions excluded
  P(3)  The number of members present at the time of voting
  P(4)  The number of members that did not abstain
  Abstention = present but not voting.

  And it identifies two types of quorums:
  (1)  A minimum number of members that must be present at the time of voting
  (2)  A minimum number of members that must not abstain
  With the added condition that you are never quorate if nobody votes.

  Quorum type (1) can be specified as a constant or it can be derived as a
  proportion of P(1) or P(2).  Quorum type (2) can be specified as a constant
  or it can be derived as a proportion of P(1), P(2), or P(3).  Note that the
  effective population size used for quorum purposes need not be the same as
  is used for determining consensus.

  The methods below don't take the nominal or current size of the voting body
  as parameters.  If the quorum is specified as a proportion of P(1) or P(2),
  the caller must reduce it to the number of members and specify quorum_type
  :num_present or :num_voting as applicable.  For example, if quorum is
  defined as 1/3 of P, Rational(P,3).ceil should be passed as the value for
  quorum.

  The remaining option is quorum type (2) defined as a proportion of P(3).
  This is supported by specifying quorum_type :proportion_voting and passing
  the proportion as a Rational value for quorum.

  Thus, the parameters related to the determination of quorum are:
  quorum_type         :num_present, :num_voting, or :proportion_voting
  quorum              Integer ≥ 1 (:num_present and :num_voting)
                      Rational, 0 < proportion ≤ 1 (:proportion_voting)
  present and voting  Integer ≥ 0, present ≥ voting

  "Measuring social consensus" also identifies four ways of setting the
  threshold for determining consensus.  Let P be the effective population
  size and let V be the number of votes in favor of some choice (0 ≤ V ≤ P):
  Majority        V > P/2
  Supermajority   V ≥ TP with 1/2 < T ≤ 1
  Near-unanimity  V ≥ P−C with 0 ≤ C < P/2
  Unanimity       V = P

  All options for determining consensus are supported by the following
  parameters:
  population      Integer P ≥ 0
  threshold_type  :majority, :supermajority, :near_unanimity, or :unanimity
  threshold       For :near_unanimity, Integer 0 ≤ C < P/2
                  For :supermajority, Rational 1/2 < T ≤ 1
                  Optional and ignored for :majority and :unanimity

  Various constraints are enforced as feasible given the other data provided
  to the different methods; for example, for a yes/no question or 1-of-M
  contest, the total number of votes cannot exceed the number of members
  present.

  The value of present (used for quorum) can exceed the value of population
  (used for consensus) when P(4) the number of members that did not abstain
  is used as the effective population size for determination of consensus.

=end --------------------------------------------------------------------------

  # Determine whether quorum is met
  # Parameters as described in the notes above
  # Returns boolean
  def self.quorate?(quorum_type, quorum, present, voting)
    check_nn_integer(present, 'present')
    check_nn_integer(voting, 'voting')
    raise 'Number voting exceeds number present' if voting > present
    case quorum_type
    when :num_present
      check_pos_integer(quorum, 'quorum')
      (present >= quorum && voting > 0)
    when :num_voting
      check_pos_integer(quorum, 'quorum')
      (voting >= quorum)
    when :proportion_voting
      check_proportion_rational(quorum, 'quorum')
      (present > 0 && Rational(voting, present) >= quorum)
    else
      raise 'Invalid quorum_type'
    end
  end

  # Evaluate threshold of consensus for a particular choice
  # votes  Integer ≥ 0
  # Other parameters as described in the notes above
  # Returns boolean
  def self.consensus?(votes, population, threshold_type, threshold=nil)
    check_nn_integer(votes, 'votes')
    check_nn_integer(population, 'population')
    raise 'Number of votes exceeds size of population' if votes > population
    case threshold_type
    when :majority
      (votes > Rational(population, 2))
    when :supermajority
      check_supermajority_rational(threshold, 'threshold T')
      (votes >= threshold * population)
    when :near_unanimity
      check_nn_integer(threshold, 'threshold C')
      raise 'Threshold C >= P/2' if threshold >= Rational(population, 2)
      (votes >= population - threshold)
    when :unanimity
      (votes == population)
    else
      raise 'Invalid threshold_type'
    end
  end

  # Elaborated yes-or-no question
  # votes_y and votes_n  Integer ≥ 0
  # Other parameters as described in the notes above
  # Returns :negative_result, :null_result, :accepted, or :rejected
  def self.question(quorum_type, quorum, present, votes_y, votes_n, population,
                    threshold_type, threshold=nil)
    check_nn_integer(votes_y, 'votes_y')
    check_nn_integer(votes_n, 'votes_n')
    check_nn_integer(present, 'present')
    check_nn_integer(population, 'population')
    voting = votes_y + votes_n
    raise 'Number of votes exceeds number present' if voting > present
    raise 'Number of votes exceeds size of population' if voting > population
    if quorate?(quorum_type, quorum, present, voting)
      if consensus?(votes_y, population, threshold_type, threshold)
        :accepted
      elsif consensus?(votes_n, population, threshold_type, threshold)
        :rejected
      else
        :negative_result
      end
    else
      :null_result
    end
  end

  # N-of-M contest
  # (For 1-of-M, see one_of_m below)
  # votes  Array of Integer ≥ 0 totalling at most N × voting
  # Other parameters as described in the notes above
  #
  # Returns :negative_result, :null_result, or an array of indices of the
  # choices in array votes that passed the threshold of consensus by
  # themselves.  No attempt is made to identify a consensus slate if one
  # exists; only the individual choices are evaluated.  
  #
  # Since N is not a parameter, the burden is partly on the caller to ensure
  # that the number of votes represented in the array votes is no greater
  # than N times the number voting.  consensus? will throw an exception if
  # any element of the array exceeds population.  n_of_m checks the upper
  # bound N = M.
  def self.n_of_m(quorum_type, quorum, present, voting, votes, population,
                  threshold_type, threshold=nil)
    check_nn_integer(present, 'present')
    check_nn_integer(voting, 'voting')
    check_array_of_nn_integer(votes, 'votes')
    check_nn_integer(population, 'population')
    vsum = votes.sum
    raise 'Number voting exceeds number present' if voting > present
    raise 'Number voting exceeds size of population' if voting > population
    raise 'Number voting exceeds number of votes' if voting > vsum
    raise 'Number of votes exceeds M times number voting' if vsum >
                                                           votes.length * voting
    if quorate?(quorum_type, quorum, present, voting)
      accepted = Array.new
      votes.each_with_index { |v,i|
        accepted.push(i) if consensus?(v, population, threshold_type, threshold)
      }
      (accepted.empty? ? :negative_result : accepted)
    else
      :null_result
    end
  end

  # 1-of-M contest
  # Mostly the same as n_of_m, but with the following simplifications for N=1:
  # - Parameter voting is removed since it must equal votes.sum
  # - Returns :negative_result, :null_result, or the index of the choice in
  #   array votes that passed the threshold of consensus
  def self.one_of_m(quorum_type, quorum, present, votes, population,
                    threshold_type, threshold=nil)
    check_array_of_nn_integer(votes, 'votes')
    ret = n_of_m(quorum_type, quorum, present, votes.sum, votes, population,
                 threshold_type, threshold)
    case ret
    when :negative_result, :null_result
      ret
    else
      raise 'Wrong number of winners' if ret.length != 1
      ret[0]
    end
  end
end
