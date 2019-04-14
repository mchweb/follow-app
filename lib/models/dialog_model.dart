class DialogModel {
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final String chat_id;
  final int unreadCount;

  DialogModel({this.name, this.avatarUrl, this.lastMessage, this.time, this.unreadCount, this.chat_id});
}

List<DialogModel> dummyData = [
  new DialogModel(
    chat_id: "5fKFw8430S1BdJNiAZ2k",
    name: "Konstantin Konstantinopolski",
    avatarUrl: "http://i.pravatar.cc/300?1",
    lastMessage: "и надо ещё какое-нибудь длинное сообщение в несколько строк, чтобы это всё красиво выглядело",
    time: "17:00",
    unreadCount: 2
  ),
  new DialogModel(
    chat_id: "cs4ItCH46zQNwRy4nd5C",
    name: "Vagiz Duseev",
    avatarUrl: "https://lh6.googleusercontent.com/-e8twoKm4EIU/AAAAAAAAAAI/AAAAAAAAAuY/0k0F3NQaneI/s96-c/photo.jpg",
    lastMessage: "эй ты епт",
    time: "16:35",
    unreadCount: 0
  ),
  /*new DialogModel(
    name: "Konstantin Konstantinopolski",
    avatarUrl: "http://i.pravatar.cc/300?5",
    lastMessage: "и надо ещё какое-нибудь длинное сообщение в несколько строк, чтобы это всё красиво выглядело",
    time: "27/01/2018 17:00",
    unreadCount: 1923567777
  ),
  new DialogModel(
    name: "Вагиз Дусеев",
    avatarUrl: "http://i.pravatar.cc/300?3",
    lastMessage: "да забей выпей винишка",
    time: "16:20",
    unreadCount: 0
  ),*/
];
