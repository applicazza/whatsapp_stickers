class WhatsappStickersException implements Exception {
  final String cause;

  WhatsappStickersException(this.cause);
}

class WhatsappStickersFileNotFoundException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersFileNotFoundException(this.cause) : super('');
}

class WhatsappStickersNumOutsideAllowableRangeException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersNumOutsideAllowableRangeException(this.cause) : super('');
}

class WhatsappStickersUnsupportedImageFormatException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersUnsupportedImageFormatException(this.cause) : super('');
}

class WhatsappStickersImageTooBigException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersImageTooBigException(this.cause) : super('');
}

class WhatsappStickersIncorrectImageSizeException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersIncorrectImageSizeException(this.cause) : super('');
}

class WhatsappStickersAnimatedImagesNotSupportedException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersAnimatedImagesNotSupportedException(this.cause) : super('');
}

class WhatsappStickersTooManyEmojisException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersTooManyEmojisException(this.cause) : super('');
}

class WhatsappStickersEmptyStringException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersEmptyStringException(this.cause) : super('');
}

class WhatsappStickersStringTooLongException extends WhatsappStickersException {
  final String cause;

  WhatsappStickersStringTooLongException(this.cause) : super('');
}
