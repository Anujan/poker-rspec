# encoding: utf-8
class Card
  attr_accessor :suit, :value
  SUITS = {
    :C    => "♣",
    :D => "♦",
    :H   => "♥",
    :S   => "♠"
  }

  VALUES = {
    :deuce => "2",
    :three => "3",
    :four  => "4",
    :five  => "5",
    :six   => "6",
    :seven => "7",
    :eight => "8",
    :nine  => "9",
    :ten   => "10",
    :jack  => "J",
    :queen => "Q",
    :king  => "K",
    :ace   => "A"
  }

  def self.suits
    SUITS.keys
  end

  def self.values
    VALUES.keys
  end

  def rank
    self.class.values.index(self.value)
  end

  def initialize(suit, value)
    raise "illegal suit" unless self.class.suits.include?(suit)
    raise "illegal value" unless self.class.values.include?(value)
    @suit = suit
    @value = value
  end

  def <=>(other)
    self.rank <=> other.rank
  end

  def ==(other)
    other.value == self.value && other.suit == self.suit
  end

  def to_s
    "#{value} of #{suit}"
  end
end

class Deck
  attr_accessor :cards

  def initialize(cards = nil)
    unless cards
      @cards = [].tap do |c|
        Card.suits.each do |suit|
          Card.values.each do |val|
            c << Card.new(suit, val)
          end
        end
      end
    else
      @cards = cards
    end
  end

  def shuffle
    self.cards.shuffle!
  end

  def count
    self.cards.count
  end

  def return(cards)
    self.cards += cards
  end

  def take(n)
    raise "not enough cards" if n > count
    self.cards.shift(n)
  end
end

class Hand
  HANDS = [
    :royal_flush,
    :straight_flush,
    :four_of_a_kind,
    :full_house,
    :flush,
    :straight,
    :three_of_a_kind,
    :two_pair,
    :one_pair,
    :high_card
  ]

  attr_accessor :cards, :deck
  def initialize(deck, *cards)
    @deck = deck
    @cards = cards
  end

  def values
    self.cards.map { |card| card.value }
  end

  def high_value
    self.values.last
  end

  def cards
    @cards.sort!
  end

  def straight?
    0.upto(3) do |idx|
      return false unless (self.cards[idx + 1].rank - self.cards[idx].rank) == 1
    end
    true
  end

  def flush?
    self.cards.all? { |card| card.suit == self.cards[0].suit }
  end

  def sames
    sames = Hash.new(0)
    self.cards.each do |card|
      sames[card.value] += 1
    end
    sames.sort_by { |k, v| v}

    sames
  end

  def value
    return [:royal_flush, :ace] if self.flush? && self.straight? && high_value == :ace
    return [:straight_flush, high_value] if self.flush? && self.straight?
    return [:four_of_a_kind, sames.keys.last] if sames.values.last == 4
    return [:full_house, sames.keys.last] if sames.values == [2, 3]
    return [:flush, high_value] if flush?
    return [:straight, high_value] if straight?
    return [:three_of_a_kind, sames.keys.last] if sames.values.last == 3
    return [:two_pair, two_pair_high] if sames.values == [1, 2, 2]
    return [:one_pair, sames.keys.last] if sames.values == [1]
    return [:high_card, high_value]
  end

  def two_pair_high
    cards = []
    self.each do |card|
      cards << card if self.sames[card.value] == 2
    end
    hand = Hand.new(cards)

    hand.high_value
  end

  def beats(other_hand)
    beat = HANDS.index(self.value.first) <=> HANDS.index(other_hand.value.first)
    case beat
    when -1
      :win
    when 0
      high_card = Card.values.index(self.value.last) <=> Card.values.index(other_hand.value.last)
      case high_card
      when -1
        :lose
      when 0
        :draw
      when 1
        :win
      end
    when 1
      :lose
    end
  end

  def replace(*args)
    if (args.count > 3)
      raise "too many cards"
    end
    args.map! { |el| el - 1 }
    deleted = []
    args.each do |c|
      raise "invalid index" unless (0...self.cards.count).include?(c)
      deleted << self.cards[c]
      self.cards[c] = deck.take(1)[0]
    end
    deck.return(deleted)
  end

  def ==(other)
    self.cards.all? do |c|
      other.cards.include?(c)
    end
  end
end

class Player
  attr_accessor :bankroll, :hand, :in_play
  attr_reader :name

  def initialize(name, bankroll, hand = [])
    @name = name
    @bankroll = bankroll
    @hand = hand
    @in_play = true
  end

  def place_bet(amt)
    raise "insufficient bankroll" if amt > bankroll
    raise "get a job" if amt < 0
    self.bankroll -= amt
  end

  def add_pot(amt)
    self.bankroll += amt
  end

  def fold
    self.in_play = false
  end

  def in_play?
    @in_play
  end
end

class Game
  attr_accessor :pot, :deck, :turn
  attr_reader :players
  def initialize(*players)
    @pot = 0
    @deck = Deck.new.shuffle
    @players = players
    @turn = @players[0]
  end
end

class Array
  def is_subset?(other_array)
    (self - other_array).empty?
  end
end