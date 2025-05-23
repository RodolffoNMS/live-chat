package zup.live_chat.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.util.HtmlUtils;
import zup.live_chat.domain.ChatInput;
import zup.live_chat.domain.ChatOutput;

import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.HashMap;
import java.util.Map;

@Controller
public class LiveChatController {

    @MessageMapping("/new-message")
    @SendTo("/topics/livechat")
    public ChatOutput newMessage(ChatInput input){
        System.out.println("Recebido: " + input);

        // Chama a Lambda via API Gateway
        RestTemplate restTemplate = new RestTemplate();
        String url = "https://wu1dj66qtf.execute-api.us-east-1.amazonaws.com/default/livechat-saveMessage"; //URL API

        Map<String, String> payload = new HashMap<>();
        payload.put("user", input.user());
        payload.put("message", input.message());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, String>> request = new HttpEntity<>(payload, headers);

        try {
            restTemplate.postForEntity(url, request, String.class);
        } catch (Exception e) {
            System.out.println("Erro ao chamar Lambda: " + e.getMessage());
        }

        return new ChatOutput(HtmlUtils.htmlEscape(input.user() + ": " + input.message()));
    }
}
