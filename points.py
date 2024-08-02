from datetime import datetime, timedelta

def total_hours_between(start_date_str, end_date_str):
    # Parse the date strings into datetime objects
    start_date = datetime.strptime(start_date_str, '%Y-%m-%d %H:%M:%S')
    end_date = datetime.strptime(end_date_str, '%Y-%m-%d %H:%M:%S')

    # Adjust the start date to the next hour if there are minutes or seconds
    if start_date.minute != 0 or start_date.second != 0:
        start_date += timedelta(hours=1)
        start_date = start_date.replace(minute=0, second=0)

    # Adjust the end date to the current hour (truncate minutes and seconds)
    end_date = end_date.replace(minute=0, second=0)

    # Calculate the total hours difference
    delta = end_date - start_date
    total_hours = delta.total_seconds() / 3600

    return int(total_hours)

def points_calculation(APY, amount, start, end):
    no_hours_per_year = 365 * 24
    hours = total_hours_between(start, end)
    points_accumulated = (APY / no_hours_per_year) * amount * hours
    return points_accumulated 

print(points_calculation(0.05, 10000, '2024-06-23 00:02:01', '2024-07-02 02:03:04'))

def calculate_net_amount(transactions, address):
    net_amount = 0.0
    amounts_list = []  # List to store each intermediate amount

    for transaction in transactions:
        # Check if the address is the sender
        if transaction['sender'] == address:
            net_amount -= float(transaction['amount'])
        # Check if the address is the recipient
        if transaction['recipient'] == address:
            net_amount += float(transaction['amount'])
        # Append the current net amount to the list after each transaction
        amounts_list.append(net_amount)

    return amounts_list

# Example transaction data
transactions = [
    {"transaction_time": "2024-03-03 04:40", "sender": "0xc59017e54b5830860687afd273527ff58f7c02b", "recipient": "0xe46ffd1b6ff4592d640ad8280440d1a85b80bd4e", "amount": "8.282384"},
    {"transaction_time": "2024-04-04 08:25", "sender": "0xe46ffd1b6ff4592d640ad8280440d1a85b80bd4e", "recipient": "0xc59017e54b5830860687afd273527ff58f7c02b", "amount": "1"},
    {"transaction_time": "2024-07-02 07:27", "sender": "0xe46ffd1b6ff4592d640ad8280440d1a85b80bd4e", "recipient": "0x4c4874cddcda0d4de10866a0c58ce27f92181d60", "amount": "2"}
]

# Address to track
wallet_address = "0xe46ffd1b6ff4592d640ad8280440d1a85b80bd4e"

# Calculate net amount and get the list of intermediate amounts
amounts_list = calculate_net_amount(transactions, wallet_address)
print("List of amounts after each transaction:", amounts_list)
