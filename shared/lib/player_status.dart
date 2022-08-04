enum PlayerStatus {
  waitingForCards,
  cardsDealt,
  playing,
  claimingBingo,
  wonBingo,
  falseBingo,
}

const statusFromString = <String, PlayerStatus>{
  playing: PlayerStatus.playing,
  waitingForCards: PlayerStatus.waitingForCards,
  cardsDealt: PlayerStatus.cardsDealt,
  claimingBingo: PlayerStatus.claimingBingo,
  falseBingo: PlayerStatus.falseBingo,
  wonBingo: PlayerStatus.wonBingo,
};

const String playing = 'playing';
const String waitingForCards = 'waiting for cards';
const String cardsDealt = 'cards dealt';
const String claimingBingo = 'claiming bingo';
const String wonBingo = 'wonBingo';
const String falseBingo = 'false bingo';

extension ReadableStatus on PlayerStatus {
  String get value {
    switch (this) {
      case PlayerStatus.playing:
        return playing;
      case PlayerStatus.waitingForCards:
        return waitingForCards;
      case PlayerStatus.claimingBingo:
        return claimingBingo;
      case PlayerStatus.cardsDealt:
        return cardsDealt;
      case PlayerStatus.wonBingo:
        return wonBingo;
      case PlayerStatus.falseBingo:
        return falseBingo;
    }
  }
}
