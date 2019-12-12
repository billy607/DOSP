let Login = {
    init(socket) { 
        let channel = socket.channel("server:lobby", {})
        channel.join()
            .receive("ok", resp => { console.log("Joined successfully", resp) })
            .receive("error", resp => { console.log("Unable to join", resp) })
        this.listenForChats(channel)
    },

    listenForChats(channel) {
        let loginButton = document.getElementById("login")
        loginButton.addEventListener("click", event =>{
            var username=document.getElementById('loginUsername').value
            var password=document.getElementById('loginPassword').value
            channel.push("login", {body: [username,password]}) 
            .receive("ok",function (reply)
            {
              if(reply.flag[0]){
                  window.location.href='main?'+encodeURI(username)+'&'+encodeURI(password)
              }else{
                  alert("login faild")
              }
            })
        })
    }
         
}

export default Login
