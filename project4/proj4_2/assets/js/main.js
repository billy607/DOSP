let Main = {
    init(socket) { 
        let channel = socket.channel("server:lobby", {})
        channel.join()
            .receive("ok", resp => { console.log("Joined successfully", resp) })
            .receive("error", resp => { console.log("Unable to join", resp) })
        this.listenForChats(channel)
    },

    listenForChats(channel) {
        var loc = location.href;
        var n1 = loc.length
        var n2 = loc.indexOf("?")
        var n3 = loc.indexOf("&")
        var username = decodeURI(loc.substring(n2+1,n3))
        var password = decodeURI(loc.substring(n3+1,n1))
        document.getElementById('title').innerHTML='Hello!!!! '+username

        let logoutButton = document.getElementById("logout")
        logoutButton.addEventListener("click", event =>{
            channel.push("logout", {body: [username,password]}) 
            .receive("ok",function (reply)
            {
              if(reply.flag){
                  window.location.href='login'
              }else{
                  alert("error")
              }
            })
        })

        let deleteButton = document.getElementById("go-delete")
        deleteButton.addEventListener("click", event =>{
            window.location.href='delete?'+encodeURI(username)+'&'+encodeURI(password)
        })
        
        let postButton = document.getElementById("post")
        postButton.addEventListener("click", event =>{
            let tweet = document.getElementById("tweetContent").value
            channel.push("sendTweet", {body: [username,tweet]})
            let msgBlock = document.createElement('p')
            msgBlock.innerHTML=tweet
            let chatBox = document.querySelector('#chat-box')
            chatBox.appendChild(msgBlock)
            console.log(tweet)
        })

        channel.on("transport", payload=>{
            var userID = payload.userID
            if(userID.includes(username)){
                console.log("success " + payload.content)
            }else{
                console.log("failed")
            }
            
        })
    }
         
}

export default Main
