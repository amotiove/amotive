#!/usr/bin/env python3

import json
import subprocess
import time
from urllib.parse import urlparse
import sys

def run_goplaces(command):
    """Run goplaces command and return JSON result"""
    try:
        result = subprocess.run(
            f"goplaces {command}",
            shell=True,
            capture_output=True,
            text=True,
            env={"GOOGLE_PLACES_API_KEY": "AIzaSyBjSA0xvDuv5Y5jXERhiU1ZcQ7HS83zA0g"}
        )
        if result.returncode == 0:
            return json.loads(result.stdout)
        else:
            print(f"Error running goplaces: {result.stderr}")
            return None
    except Exception as e:
        print(f"Exception running goplaces: {e}")
        return None

def fetch_website(url):
    """Fetch website content using web_fetch tool"""
    # This would need to be implemented via OpenClaw tool call
    # For now, return placeholder
    return {"status": "pending", "url": url}

def score_website(url, content):
    """Score website quality"""
    if not url:
        return "❌ NO_SITE"
    
    if content.get("status") == "error" or "error" in content.get("text", "").lower():
        return "🔴 TERRIBLE"
    
    # Basic scoring logic - can be enhanced
    text = content.get("text", "").lower()
    if "coming soon" in text or len(text) < 200:
        return "🔴 TERRIBLE"
    elif "copyright 20" in text and "2020" in text:
        return "🟡 OUTDATED"
    else:
        return "🟢 DECENT"

# Sample place IDs from searches (this will be populated with actual data)
place_ids = [
    "ChIJqxZaZLY-kFQRFQYp0EAtG5I",  # Doc's Marina Grill
    "ChIJtyJhy8o-kFQRDSFeSJGnW2c",  # Progressive Electric
    "ChIJ5wFEZiU_kFQRLS6uIS4U7QA",  # Cake for Breakfast
    # ... more place IDs
]

def main():
    businesses = []
    
    print("Processing place details...")
    for place_id in place_ids:
        details = run_goplaces(f"details {place_id} --json")
        if details:
            business = {
                "place_id": place_id,
                "name": details.get("name"),
                "address": details.get("address"),
                "phone": details.get("phone"),
                "website": details.get("website"),
                "rating": details.get("rating"),
                "user_rating_count": details.get("user_rating_count"),
                "types": details.get("types", [])
            }
            businesses.append(business)
            print(f"Processed: {business['name']}")
        
        time.sleep(0.1)  # Rate limiting
    
    return businesses

if __name__ == "__main__":
    businesses = main()
    print(f"Processed {len(businesses)} businesses")