let Register = {
    init(socket) {
        let channel = socket.channel("server:lobby", {})
        channel.join()
            .receive("ok", resp => { console.log("Joined successfully2", resp) })
            .receive("error", resp => { console.log("Unable to join", resp) })
        this.listenForChats(channel)
    },

    listenForChats(channel) {
        let registerButton = document.querySelector("#register")
        registerButton.addEventListener("click", event =>{
            var username=document.getElementById('registerUsername').value
            var password=document.getElementById('registerPassword').value
            channel.push('register', {body: [username,password]})
            .receive("ok",function (reply)
            {
              if(reply.flag){
                  alert("register success")
              }else{
                  alert("register faild")
              }
            })
        })

        // channel.on('respond', payload => {
        //     let chatBox = document.querySelector('#chat-box')
        //     let msgBlock = document.createElement('p')
      
        //     msgBlock.insertAdjacentHTML('beforeend', `<b>${payload.name}:</b> ${payload.body}`)
        //     chatBox.appendChild(msgBlock)
        // })
    }     
}

export default Register
