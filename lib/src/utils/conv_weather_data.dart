class WeatherInfoConverter {
  static getSkyType(skyInt) {
    switch (skyInt) {
      case '1':
        return '맑음';
      case '3':
        return '구름 많음';
      case '4':
        return '흐림';
      default:
        return '데이터 로드 실패';
    }
  }

  static getRainType(rainInt) {
    switch (rainInt) {
      case '0':
        return '강수 예정 없음';
      case '1':
        return '비';
      case '2':
        return '비/눈';
      case '3':
        return '눈';
      case '5':
        return '빗방울';
      case '6':
        return '빗방울 눈날림';
      case '7':
        return '눈날림';
      default:
        return '데이터 로드 실패';
    }
  }
}
