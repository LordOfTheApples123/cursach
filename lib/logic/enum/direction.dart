enum Direction {
  u,
  ur,
  r,
  dr,
  d,
  dl,
  l,
  ul;

  Direction opposite() {
    switch (this) {
      case u:
        return d;
      case ur:
        return dl;
      case r:
        return l;
      case dr:
        return ul;
      case d:
        return u;
      case dl:
        return ur;
      case l:
        return r;
      case ul:
        return dr;
    }
  }

  int toIndex() {
    switch (this) {
      case u:
        return 7;
      case ur:
        return 8;
      case r:
        return 12;
      case dr:
        return 17;
      case d:
        return 16;
      case dl:
        return 15;
      case l:
        return 11;
      case ul:
        return 6;
    }
  }
}
