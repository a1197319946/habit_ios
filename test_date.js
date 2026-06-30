const testDates = ['2023-10-01', '2023-10-02', '2023-10-31', '2024-02-29', '2023-12-31'];
for (const dateStr of testDates) {
  const now = new Date(dateStr);
  const day = now.getDay();
  const diff = day === 0 ? 6 : day - 1;
  const monday = new Date(now);
  monday.setDate(now.getDate() - diff);
  const sunday = new Date(monday);
  sunday.setDate(monday.getDate() + 6);
  
  const startStr = [monday.getFullYear(), String(monday.getMonth()+1).padStart(2,'0'), String(monday.getDate()).padStart(2,'0')].join('-');
  const endStr = [sunday.getFullYear(), String(sunday.getMonth()+1).padStart(2,'0'), String(sunday.getDate()).padStart(2,'0')].join('-');
  
  console.log(`${dateStr} -> Week: ${startStr} to ${endStr}`);
}
