let Delete = {
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
        
        let deleteButton = document.getElementById("delete")
        deleteButton.addEventListener("click", event =>{
            channel.push("delete", {body: [username,password]}) 
            .receive("ok",function (reply)
            {
              if(reply.flag){
                  window.location.href='login'
              }else{
                  alert("wrong password")
              }
            })
        })
    }
         
}

export default Delete
