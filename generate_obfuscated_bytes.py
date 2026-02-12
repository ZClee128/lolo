#!/usr/bin/env python3
# generate_obfuscated_bytes.py
# Generate correct XOR-encoded byte arrays for strings

def xor_encode(text, key="LOLO"):
    """XOR encode a string with a repeating key"""
    key_bytes = [ord(c) for c in key]
    result = []
    for i, char in enumerate(text):
        key_byte = key_bytes[i % len(key_bytes)]
        encoded = ord(char) ^ key_byte
        result.append(f"@{encoded}")
    return ", ".join(result)

# Strings to encode
strings_to_encode = {
    "avatarBaseURL": "https://i.pravatar.cc/150?u=",
    "placeholderImageBaseURL": "https://picsum.photos/",
    "notificationNameCoinsBalanceChanged": "LOLOCoinsBalanceDidChangeNotification",
    "notificationNameAccountDeleted": "LOLOAccountDeletedNotification",
    "notificationNameTermsAgreed": "LOLOTermsAgreedNotification",
    "userDefaultsKeyCurrentUserId": "LOLO_CurrentUserId",
    "userDefaultsKeyHasAgreedToTerms": "LOLO_HasAgreedToTerms",
    "userDefaultsKeyUserCreatedPosts": "LOLO_UserCreatedPosts",
    "userDefaultsKeyBlockedUsers": "LOLO_BlockedUsers",
}

print("// Generated XOR-encoded byte arrays\n")
for name, text in strings_to_encode.items():
    encoded = xor_encode(text)
    print(f"// {name}: \"{text}\"")
    print(f"NSArray *bytes = @[{encoded}];")
    print()
