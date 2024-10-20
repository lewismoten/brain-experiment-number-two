key callerId;
string callerName;
integer listener;
string botid = "c94b411cbe36eca9";
string skin = "bare";
string url = "http://pandorabots.com/pandora/talk?botid=c94b411cbe36eca9&skin=bare";
key requestId;
string botcust2;
string parseResponse(string text)
{
    integer i = llSubStringIndex(text, "value=\"");
    text = llGetSubString(text, i + 7, -1);
    i = llSubStringIndex(text, "\"");
    botcust2 = llGetSubString(text, 0, i-1);
    i = llSubStringIndex(text, ">");
    text = llGetSubString(text, i + 1, -1);
    return text;
}
init()
{
    callerId = NULL_KEY;
    callerName = "";
    botcust2 = "";
    stopListening();
    emote("floats about waiting patiently.");
}
emote(string message)
{
    string name = llGetObjectName();
    llSetObjectName("The brain");
    llSay(PUBLIC_CHANNEL, "/me " + message);
    llSetObjectName(name);
}
detectedEmote(string message, integer i)
{
    string name = llGetObjectName();
    llSetObjectName(llDetectedName(i));
    llSay(PUBLIC_CHANNEL, "/me " + message);
    llSetObjectName(name);
}
dial(integer i)
{
    if(callerId != NULL_KEY)
    {
        if(callerId == llDetectedKey(i))
        {
            detectedEmote("hangs up the phone.", i);
            callerId = NULL_KEY;
            stopListening();
            return;
        }
        detectedEmote("picks up the phone and hears a busy signal on the other end.", i);
        return;
        
    }
    detectedEmote("picks up the phone.", i);
    
    llInstantMessage(llDetectedKey(i), "All conversations are logged so that the creator (Dedric Mauriac) can help the AI get smarter over time. Touch the phone again to have it stop listening.");
    
    startListening(i);
}
startListening(integer i)
{
    stopListening();
    callerId = llDetectedKey(i);
    callerName = llDetectedName(i);
    listener = llListen(PUBLIC_CHANNEL, callerName, callerId, "");
    newRequest();
    llSetTimerEvent(60);
}
newRequest()
{
    requestId = llHTTPRequest(url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "input=" + llEscapeURL("Hello. My name is " + callerName));
}
newResponse(string text)
{
    requestId = llHTTPRequest(url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], "input=" + llEscapeURL(text) + "&botcust2=" + llEscapeURL(botcust2));
}
keepListening()
{
    llSetTimerEvent(60);
}
stopListening()
{
    llSetTimerEvent(0);
    if(listener != 0)
    {
        llListenRemove(listener);
        listener = 0;
    }
    if(callerName != "")
    {
        newResponse("I am hanging up");
        emote("good bye");
    }
    if(callerId != NULL_KEY)
        emote("decided to hang up after hearing dead air.");
    callerId = NULL_KEY;
    callerName = "";
}
default
{
    state_entry()
    {
        init();
    }
    on_rez(integer start_param)
    {
        init();
    }
    timer()
    {
        stopListening();
    }
    listen(integer channel, string name, key id, string message)
    {
        keepListening();
        newResponse(message);
    }
    http_response(key request_id, integer status, list metadata, string body)
    {
        if(request_id != requestId) return;
        if(callerName != "")
            llSay(PUBLIC_CHANNEL, parseResponse(body));
    } 
    touch_start(integer total_number)
    {
        integer i;
        for(i = 0; i < total_number; i++)
        {
            string linkName = llGetLinkName(llDetectedLinkNumber(i));
            
            if(linkName == "Phone")
                dial(i);
            else if(linkName == "Jar of Nuts")
                detectedEmote("shakes the jar of nuts and wonders how many are inside.", i);
            else if(linkName == "Nuts")
                detectedEmote("takes a nut out of the jar and examines it. Yep. That's a nut.", i);
            else if(linkName == "Brain Flakes")
                detectedEmote("shakes some brain flakes and watches the brain swim up to feed.", i);
            else if(llDetectedLinkNumber(i) == LINK_ROOT)
                detectedEmote("taps on the glass. The brain slowly floats closer.", i);
            else if(linkName == "White Wire")
                detectedEmote("looks at the white wire and wonders how a phone can be connected directly to a brain.", i);
            else if(linkName == "Red Wire")
                detectedEmote("moves the red wire a little and looks around at the brain.", i);
            else if(linkName == "Black Wire")
                detectedEmote("can see that the black wire is securely fastened to the brain.", i);
            else if(linkName == "Battery")
                detectedEmote("looks behind the brain at the 9 volt battery.", i);
            else if(linkName == "Battery +")
                detectedEmote("thinks about sticking their tongue on the 9 vold batter, but thinks twice looking at the fate of the last persons brain who tried the same.", i);
            else if(linkName == "Battery -")
                detectedEmote("notices some sparks comming from the battery hooked up to the brain.", i);
            else if(linkName == "Black Clamp")
                detectedEmote("wonders what color is positive and negative.", i);
            else if(linkName == "Red Clamp")
                detectedEmote("hadn't realized there was such a thing as brain clamps before.", i);
            else if(linkName == "Liquid")
                detectedEmote("peers into the liquid at the brain. The stench knocks them back.", i);
            else if(linkName == "Brain")
                detectedEmote("reaches their hand into the liquid and pokes their fingers deep into the brain.", i);
            else
                detectedEmote("bumps into the experiment and looks at the phone.", i);
        }
    }
}
