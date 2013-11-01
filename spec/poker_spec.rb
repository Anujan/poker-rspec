require 'rspec'
require 'poker'

describe "Poker" do
  describe Card do
    subject(:card) { Card.new(:C, :king) }

    its(:suit) { should == :C }
    its(:value) { should == :king }

    it "should throw exception if suit does not exist" do
      expect{Card.new(:G, :king)}.to raise_error "illegal suit"
    end

    it "should throw exception if value does not exist" do
      expect{Card.new(:C, :nope)}.to raise_error "illegal value"
    end
  end

  describe Deck do
    subject(:deck) { Deck.new }

    it "should be 52 uniq cards" do
      deck.cards.uniq.count.should eq(52)
    end

    describe "#count" do
      it "should return number of cards" do
        deck.count.should eq(52)
      end
    end

    describe "#shuffle" do
      let(:old_deck) { deck }

      it "should shuffle the deck" do
        deck.shuffle
        expect{ deck.cards }.to_not eql(old_deck.cards)
      end
    end

    describe "#return" do
      let(:returned) { [Card.new(:C, :king), Card.new(:S, :seven)] }
      before do
        deck.return(returned)
      end

      it "should add the proper number of cards to the deck" do
        deck.count.should eq(54)
      end

      it "should add the right cards to the deck" do
        deck.cards[-2..-1].should eq(returned)
      end
    end

    describe "#take" do
      let(:taken) { deck.take(3) }

      it "should return the proper number of cards" do
        taken.count.should eq(3)
      end

      it "should return an array of cards" do
        expect{taken.all? { |card| card.is_a?(Card) }}.to be_true
      end

      it "should reduce the deck size by number of cards taken" do
        deck.take(3)
        deck.count.should eq(49)
      end

      it "should raise an exception if there aren't enough cards" do
        expect{ deck.take(100) }.to raise_error "not enough cards"
      end
    end
  end

  subject(:hand) { Hand.new(
    deck, Card.new(:D, :jack), Card.new(:D, :ten), Card.new(:D, :nine),
    Card.new(:D, :eight), Card.new(:D, :seven)
    )
  }

  describe Hand do
    let(:deck) { Deck.new([Card.new(:S, :four),
      Card.new(:H, :three), Card.new(:H, :eight)]) }

    let(:draw_hand) { Hand.new(deck,
      Card.new(:C, :jack), Card.new(:C, :ten), Card.new(:C, :nine),
      Card.new(:C, :eight), Card.new(:C, :seven)
      )
    }

    let(:win_hand) { Hand.new(deck,
      Card.new(:D, :ace), Card.new(:D, :king), Card.new(:D, :queen),
      Card.new(:D, :jack), Card.new(:D, :ten)
      )
    }

    let(:loser_hand) { Hand.new(deck,
      Card.new(:D, :ace), Card.new(:D, :ace), Card.new(:D, :ace),
      Card.new(:D, :jack), Card.new(:C, :ten)
      )
    }

    describe "#value" do
      it "should calculate hand value" do
        hand.value.should eq([:straight_flush, :jack])
      end
    end

    describe "#beats" do
      it "should determine if it is a draw" do
        hand.beats(draw_hand).should eq(:draw)
      end

      it "should determine if it is a win" do
        hand.beats(loser_hand).should eq(:win)
      end

      it "should determine if it is a loss" do
        hand.beats(win_hand).should eq(:lose)
      end
    end

    describe "#replace" do
      describe "valid moves" do
        before { hand.replace(1, 3) }

        it "should not change the number of cards in the hand" do
          hand.cards.count.should eq(5)
        end

        it "should replace the correct cards" do
          hand.cards.include?(Card.new(:D, :jack)).should be_false
          hand.cards.include?(Card.new(:D, :nine)).should be_false
        end

        it "should add the top cards from the deck" do
          [Card.new(:S, :four), Card.new(:H, :three)].all? do |card|
            hand.cards.include?(card)
          end.should be_true
        end
      end

      it "should raise error if you try to replace more than 3
          cards" do
          expect { hand.replace(1, 3, 4, 5) }.to raise_error "too many cards"
      end

      it "should raise error if you supply invalid index" do
        expect { hand.replace(5, 6) }.to raise_error "invalid index"
      end
    end
  end

  describe Player do
    subject(:player) { Player.new("Joe", 20000, hand) }
    its(:name) { should == "Joe" }
    its(:bankroll) { should == 20000 }
    its(:hand) { should == Hand.new(deck, Card.new(:D, :jack),
      Card.new(:D, :ten), Card.new(:D, :nine),Card.new(:D, :eight), Card.new(:D, :seven)) }

    describe "#place_bet" do
      it "should modify the bankroll" do
        player.place_bet(4000)
        player.bankroll.should eql(16000)
      end

      it "should raise error if bet is too high" do
        expect{ player.place_bet(100347) }.to raise_error
        "insufficient bankroll"
      end

      it "should raise error if bet is negative" do
        expect{ player.place_bet(-97) }.to raise_error
        "get a job"
      end
    end

    describe "#add_pot" do
      it "should modify the bankroll correctly" do
        player.add_pot(3)
        player.bankroll.should eql(20003)
      end
    end

    describe "#play_turn" do
      describe "#fold" do
        it "should take the player out of the game" do
          player.fold
          player.should_not be_in_play
        end
      end
    end
  end

  describe Game do
    subject(:game) { Game.new }
    its(:pot) { should == 0 }
    its("deck.count") { should == 52 }
    its(:turn) { should == game.players[0]}

    describe "#take_bets" do
      it "should add bets to the pot" do
      end
    end

    describe "#pay_bets" do
    end

    describe "#winner" do

    end
  end
end