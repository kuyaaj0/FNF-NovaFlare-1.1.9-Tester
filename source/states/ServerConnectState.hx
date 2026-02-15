package states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.Timer;
import sys.Http;
import sys.net.Host;
import sys.net.Socket;
import hx.ws.WebSocket;
import cpp.vm.Thread;

class ServerConnectState extends MusicBeatState
{
    var statusText:FlxText;
    var wsThread:Thread;
    var ws:WebSocket;
    var token:String;
    var lastMessage:String = "";

    override function create()
    {
        super.create();
        
        statusText = new FlxText(0, 0, 0, "Start...", 32);
        statusText.screenCenter();
        add(statusText);
        
        Thread.create(function() {
            authenticate();
        });
    }

     function authenticate()
    {
        try {
            var deviceId = "flixel-" + Std.string(Math.random()) + "-" + Std.string(Math.random());
            deviceId = deviceId.substr(0, 32);
            
            var url = "http://127.0.0.1:7350/v2/account/authenticate/device?create=true";
            var http = new Http(url);
            
            http.setHeader("Content-Type", "application/json");
            http.setHeader("Authorization", "Basic ZGVmYXVsdGtleTo=");
            
            var body = Json.stringify({ id: deviceId });
            http.setPostData(body);
            
            http.onData = function(data:String) {
                trace("✅ 认证成功");
                var response = Json.parse(data);

                connectWebSocket(response.token);
            };
            
            http.onError = function(error:String) {
                trace("❌ 认证失败: " + error);
            };
            
            http.request(true);
            
        } catch(e:Dynamic) {
            trace("❌ 异常: " + e);
        }
    }

    function connectWebSocket(token)
    {
        try {
            ws = new WebSocket("ws://127.0.0.1:7350/ws?token=" + token);
            trace("✅WebSocket连接成功");
            
            ws.onopen = function() {
 
            var msg = {
                cid: "1",
                rpc: {
                    id: "welcome",
                    payload: "Hello from Flixel CPP!"
                }
            };
            
            var json = Json.stringify(msg);
            ws.send(json);
        };
            
            ws.onmessage = function(msg:Dynamic) {
                trace("服务器消息" + msg);
            };
            
            ws.onclose = function() {
                trace("连接已关闭");
            };
            
            ws.onerror = function(msg:String) {
                trace("WebSocket错误: " + msg);
            };
        } catch(e:Dynamic) {
            trace("❌ WebSocket 错误: " + e);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (controls.BACK)
        {
            if (ws != null) {
                ws.close();
                ws = null;
            }
            MusicBeatState.switchState(new MainMenuState());
        }
    }
}
