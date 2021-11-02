# ข้อควรระวังเกี่ยวกับการ import file .data

1. add or create design source
2. add files
3. เลือก files of types = All Files (อยู่บนๆ เลื่อนขึ้นไป)
4. หลังจากนั้นจะได้ไฟล์ในโฟลเดอร์ unknown
5. คลิกขวาที่ไฟล์ เลือก set file type > Data List แล้วไปกด used in เลือกติ๊ก 2 อัน

* system ของข้อนี้ คือ ***nano_sc_system.v***
* oldmemory คือ memory ที่เหมือนกับต้นฉบับในเว็บ https://www.cp.eng.chula.ac.th/~krerk/books/Computer%20Architecture/nanoLADA/
* โค้ดส่วนที่ต่างจากต้นฉบับในเว็บ (major change) ได้แก่ ALU, control, nanocpu, nano_sc_system
* มี minor change บางส่วนในบาง module ซึ่งไม่ได้ส่งผลอะไรถ้าไม่ได้แก้ตาม