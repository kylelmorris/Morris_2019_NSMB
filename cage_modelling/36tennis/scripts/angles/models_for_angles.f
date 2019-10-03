c
      character*80 pdb(1000000),line,fnam*25
      integer idxmod(100)
c
      open(unit=1,file='All_models_proximal_in_X_rot_180.pdb',
     1 form='formatted',status='old')
c
      i = 0
 1000 read(1,5000,end=1100) line
      i = i + 1
      if (line(1:5) .eq. 'MODEL') then
         read(line(11:14),fmt='(i4)') num
         idxmod(num) = i
      endif
      pdb(i) = line
      goto 1000
 1100 continue
      nl = i
      nmod = num
c
      write(6,*) nl,' lines and ',nmod,' models'
c
      do 10 i=2,nmod
         fnam = 'split_'//pdb(idxmod(i)+1)(9:23)//'.pdb'
         open(2,file=fnam,form='formatted',status='unknown')
         icur = i
         call wrsplit(2,pdb,idxmod,icur,nmod,nl)
         close(2)
 10   continue
c
      STOP
c
 5000 format(a80)
c
      end
c
c

      subroutine wrsplit(iout,pdb,idxmod,icur,nmod,nl)
c
      character*80 pdb(1000000),line
      integer idxmod(100),idx(1000000)
c
      write(iout,6000) icur
c
c-----find and write out the appropriate sections with new MODEL
c     records for each segement or domain
      ifst = idxmod(icur) + 2
      if (icur .eq. nmod) then
         ilst = nl
      else
         ilst = idxmod(icur+1) - 1
      endif
c
      iend = 0
      write(6,*) 'ifst ',ifst,' ilst ',ilst
      do 10 il=ifst,ilst
         if (pdb(il)(1:3) .eq. 'TER') then
            iend = il
         endif
         read(pdb(il)(23:26),fmt='(i4)') ires
         idx(il) = 0
c        
         if (iend .eq. 0 ) then
            if (ires .ge. 1 .and. ires .le. 507) idx(il) = 1
            if (ires .eq. 507) idx(il) = 2
c
            if (ires .ge. 560 .and. ires .le. 834) idx(il) = 1
            if (ires .eq. 834) idx(il) = 2
c
            if (ires .ge. 839 .and. ires .le. 1133) idx(il) = 1
            if (ires .eq. 1133) idx(il) = 2
c
            if (ires .ge. 1135 .and. ires .le. 1278) idx(il) = 1
            if (ires .eq. 1278) idx(il) = 2
c
            if (ires .ge. 1284 .and. ires .le. 1594) idx(il) = 1
            if (ires .eq. 1594) idx(il) = 2
c
            if (ires .ge. 1596 .and. ires .le. 1630) idx(il) = 1
            if (ires .eq. 1630) idx(il) = 2
         endif
c
 10   continue
c
      write(6,*) 'iend ',iend 
      imod = 1
      write(iout,6010) imod 
      do 20 il=ifst,iend
C         write(6,*) 'IDX ',idx(il)
         if (idx(il) .gt. 0) write(iout,6030) pdb(il)
         if (idx(il) .gt. 1) then
            imod = imod + 1
            write(iout,6020)
            write(iout,6010) imod   
         endif
c         if (idx(il) .gt. 1) write(iout,6010) 
 20   continue
      write(iout,6020) 
c
      return
c
 6000 format('REMARK domains split into MODELs for structure number:',
     1 i3)
 6010 format('MODEL',5x,i5)
 6020 format('ENDMDL')
 6030 format(a80)
c
      end
c
c
