const stompClient = new StompJs.Client({
    brokerURL: 'ws://' + window.location.host + '/livechat'
});

stompClient.onConnect = (frame) => {
    setConnected(true);
    console.log('Connected: ' + frame);
    stompClient.subscribe('/topics/livechat', (message) => {
        updateLiveChat(JSON.parse(message.body).content);
    });
};

stompClient.onWebSocketError = (error) => {
    console.error('Error with websocket', error);
};

stompClient.onStompError = (frame) => {
    console.error('Broker reported error: ' + frame.headers['message']);
    console.error('Additional details: ' + frame.body);
};

function setConnected(connected) {
    $("#connect").prop("disabled", connected);
    $("#disconnect").prop("disabled", !connected);
    if (connected) {
        $("#conversation").show();
    }
    else {
        $("#conversation").hide();
    }
}

function connect() {
    stompClient.activate();
    loadMessages(); // Carrega mensagens existentes
}

function disconnect() {
    stompClient.deactivate();
    setConnected(false);
    console.log("Disconnected");
}

function sendMessage() {
    stompClient.publish({
        destination: "/app/new-message",
        body: JSON.stringify({'user': $("#user").val(), 'message': $("#message").val()})
    });
    $("#message").val("");
}

function updateLiveChat(message) {
    $("#livechat").append("<tr><td>" + message + "</td></tr>");
}

$(function () {
    $("form").on('submit', (e) => e.preventDefault());
    $( "#connect" ).click(() => connect());
    $( "#disconnect" ).click(() => disconnect());
    $( "#send" ).click(() => sendMessage());
});


// Recuperar mensagens:
function loadMessages() {
    $.ajax({
        url: 'https://wu1dj66qtf.execute-api.us-east-1.amazonaws.com/default/livechat-recoverMessage',
        method: 'GET',
        success: function(response) {
            const messages = response.messages;
            $("#livechat").empty(); // Limpa mensagens existentes

            // Adiciona as mensagens ao chat
            messages.forEach(function(item) {
                updateLiveChat(item.user + ": " + item.message);
            });

            console.log("Carregadas " + messages.length + " mensagens");
        },
        error: function(error) {
            console.error("Erro ao carregar mensagens:", error);
        }
    });
}