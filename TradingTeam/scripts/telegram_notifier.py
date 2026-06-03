import json
import ssl
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


def send_telegram_message(token: str, chat_id: str, text: str, parse_mode: str = "Markdown") -> dict:
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": parse_mode,
    }
    
    # Bypass SSL verification if needed (not recommended but for local environments sometimes necessary)
    context = ssl._create_unverified_context()
    
    request = Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    
    try:
        with urlopen(request, context=context, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
    except (HTTPError, URLError) as e:
        print(f"Telegram API Error: {e}", file=sys.stderr)
        if isinstance(e, HTTPError):
            print(f"Error detail: {e.read().decode('utf-8')}", file=sys.stderr)
        raise


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python telegram_notifier.py <token> <chat_id> <text>")
        sys.exit(1)
        
    token_arg = sys.argv[1]
    chat_id_arg = sys.argv[2]
    text_arg = " ".join(sys.argv[3:])
    
    try:
        res = send_telegram_message(token_arg, chat_id_arg, text_arg)
        if res.get("ok"):
            print("Message sent successfully.")
        else:
            print(f"Failed to send: {res}")
            sys.exit(1)
    except Exception as exc:
        print(f"Fatal error: {exc}")
        sys.exit(1)
