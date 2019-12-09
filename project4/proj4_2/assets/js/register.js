// import {Socket} from "phoenix"

// let socket = new Socket("/socket", {params: {token: window.userToken}})
import "phoenix_html"
import css from "../css/app.css"


window.read = function(){ 
    var username=document.getElementById('username').value
    var password=document.getElementById('password').value
    alert(username)
}

// socket.connect()

// // Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("topic:subtopic", {})
// channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   .receive("error", resp => { console.log("Unable to join", resp) })



// export default socket