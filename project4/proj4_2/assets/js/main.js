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
        channel.push("init", {body: [username,password]})
        .receive("ok",function(reply){
            var tweet_list=reply.flag[1]
            let chatBox = document.querySelector('#chat-box')
            for(var i=0;i<tweet_list.length;i++){
                let msgBlock = document.createElement('p')
                msgBlock.setAttribute("id",tweet_list[i][0])
                msgBlock.setAttribute('onclick','document.getElementById("tweetContent").value=event.target.id;')
                msgBlock.onmouseout  = function(){
                    msgBlock.setAttribute('style','color:black')
                };
                msgBlock.onmouseover = function(){
                    msgBlock.setAttribute('style','color:blue')
                };
                msgBlock.innerHTML=tweet_list[i][1]+":"+tweet_list[i][2]
                chatBox.appendChild(msgBlock)
            }
        }) 
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
        
        let subscribeButton = document.getElementById("subscribe") 
        subscribeButton.addEventListener("click", event =>{
            let subseribedName = document.getElementById("subscribe_content").value
            channel.push("subscribe", {body: [username,subseribedName]}) 
            .receive("ok",function (reply)
            {
              if(reply.flag){
                  alert("subscribe success")
              }else{
                  alert("no such user")
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
            msgBlock.innerHTML=username+":"+tweet
            let chatBox = document.querySelector('#chat-box')
            chatBox.appendChild(msgBlock)
            console.log(tweet)
        })

        channel.on("transport", payload=>{
            if(payload.userID.includes(username)||payload.follower.includes(username)){
                let sender=payload.senderName
                let tweet = payload.content
                let msgBlock=document.createElement('p')
                msgBlock.innerHTML=sender+":"+tweet
                let chatBox=document.querySelector('#chat-box')
                chatBox.appendChild(msgBlock)
            }else{
                console.log("failed")
            }
            
        })
    }
         
}

export default Main
