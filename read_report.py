
try:
    with open('analysis_report.txt', 'r', encoding='utf-16-le') as f:
        print(f.read()[:2000]) # First 2000 chars
except Exception as e:
    print(f"Error reading utf-16-le: {e}")
    try:
        with open('analysis_report.txt', 'r', encoding='utf-8') as f:
            print(f.read()[:2000])
    except Exception as e2:
        print(f"Error reading utf-8: {e2}")
