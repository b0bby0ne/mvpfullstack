import json
import ssl
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def get_updates(token: str) -> dict:
    url = f"https://api.telegram.org/bot{token}/getUpdates"
    context = ssl._create_unverified_context()
    request = Request(url)
    
    try:
        with urlopen(request, context=context, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
    except (HTTPError, URLError) as e:
        print(f"Telegram Updates Error: {e}", file=sys.stderr)
        raise


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python get_telegram_chat_id.py <bot_token>")
        sys.exit(1)
        
    token_arg = sys.argv[1]
    print(f"Checking for updates for bot token: {token_arg}")
    print("TIP: Send a message to your bot now to see your Chat ID.")
    
    try:
        res = get_updates(token_arg)
        if not res.get("ok"):
            print(f"Error fetching updates: {res}")
            sys.exit(1)
            
        results = res.get("result", [])
        if not results:
            print("No updates found. Please send a message to the bot and try again.")
            sys.exit(0)
            
        print("\n--- Latest Updates Found ---")
        for upd in results:
            msg = upd.get("message", {})
            chat = msg.get("chat", {})
            sender = msg.get("from", {})
            text = msg.get("text", "")
            
            print(f"From: {sender.get('first_name')} (@{sender.get('username')})")
            print(f"Chat ID: {chat.get('id')}")
            print(f"Text: {text}")
            print("------------------------------")
            
        print("\nPlease use the Chat ID above in your configuration.")
    except Exception as exc:
        print(f"Fatal error: {exc}")
        sys.exit(1)
