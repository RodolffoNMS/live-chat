package zup.live_chat.domain;

public record ChatInput(String user, String message, String roomId, String userType) { }
