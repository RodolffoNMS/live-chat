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
  document.getElementById("connect").disabled = connected;
  document.getElementById("disconnect").disabled = !connected;
  document.getElementById("conversation").style.display = connected ? "" : "none";
}

function connect() {
  stompClient.activate();
  loadMessages();
}

function disconnect() {
  stompClient.deactivate();
  setConnected(false);
  console.log("Disconnected");
}

function sendMessage() {
  const user = document.getElementById("user").value;
  const message = document.getElementById("message").value;
  if (user && message) {
    stompClient.publish({
      destination: "/app/new-message",
      body: JSON.stringify({ user, message })
    });
    document.getElementById("message").value = "";
  }
}

function updateLiveChat(message) {
  const tbody = document.getElementById("livechat");
  const tr = document.createElement("tr");
  const td = document.createElement("td");
  td.textContent = decodeHtml(message); // decodifica entidades HTML
  tr.appendChild(td);
  tbody.appendChild(tr);
  // Rola para o final
  const chatScroll = document.getElementById("chat-scroll");
  chatScroll.scrollTop = chatScroll.scrollHeight;
}

function loadMessages() {
  fetch('https://wu1dj66qtf.execute-api.us-east-1.amazonaws.com/default/livechat-recoverMessage')
    .then(response => response.json())
    .then(data => {
      const messages = data.messages;
      const tbody = document.getElementById("livechat");
      tbody.innerHTML = "";
      messages.forEach(item => {
        updateLiveChat(item.user + ": " + item.message);
      });
      console.log("Carregadas " + messages.length + " mensagens");
    })
    .catch(error => {
      console.error("Erro ao carregar mensagens:", error);
    });
}

document.addEventListener("DOMContentLoaded", function () {
  // Previne submit padrão do form
  document.querySelectorAll("form").forEach(form => {
    form.addEventListener("submit", (e) => e.preventDefault());
  });
  document.getElementById("connect").addEventListener("click", connect);
  document.getElementById("disconnect").addEventListener("click", disconnect);
  document.getElementById("send").addEventListener("click", sendMessage);
});

function decodeHtml(html) {
  const txt = document.createElement('textarea');
  txt.innerHTML = html;
  return txt.value;
}

document.addEventListener("DOMContentLoaded", function () {
  // Previne submit padrão do form
  document.querySelectorAll("form").forEach(form => {
    form.addEventListener("submit", (e) => e.preventDefault());
  });

  const userInput = document.getElementById("user");
  const connectBtn = document.getElementById("connect");

  // Desabilita o botão inicialmente
  connectBtn.disabled = true;

  userInput.addEventListener("input", function () {
    connectBtn.disabled = userInput.value.trim() === "";
  });

  document.getElementById("connect").addEventListener("click", connect);
  document.getElementById("disconnect").addEventListener("click", disconnect);
  document.getElementById("send").addEventListener("click", sendMessage);
});