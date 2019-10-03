c
      character*80 line(10000)
c
      il = 1
 1000 read(5,5000,end=1100) line(il)
         il = il + 1
         goto 1000
 1100 continue
c
      nl = il - 1
c
      do 10 il=1,nl-4
         if (index(line(il),'Inertia axes') .ne. 0) then
            write(6,6000) line(il)(1:73)
            do 20 jl=il+1,il+3
               write(6,6010) line(jl)(2:72)
 20         continue
            write(6,6000) line(il+4)(1:73)
          endif
 10   continue
c
      STOP
c
 5000 format(a80)
 6000 format('REMARK ',a73)
 6010 format('REMARK ',a72)
c
      end
c
c
