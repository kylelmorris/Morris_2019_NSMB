c     This code generates all the windows to calculate. Hacked from 
c     bude_scan.f
c
      integer MXATPC,MXCHN,MXRES
      parameter(MXATPC=20000,MXCHN=20,MXRES=2000)
      character*80 pdb(MXATPC,MXCHN),line,curchn*1,curres*9,awin*11,
     1 ichtyp(MXCHN)*1,mol2(MXATPC*MXCHN),header(1000),shift*24
      integer ichf(MXCHN),ichl(MXCHN),iresf(MXRES,MXCHN),
     1 iresl(MXRES,MXCHN),nrspch(MXCHN),isrec(MXATPC,MXCHN),
     2 winwid,hwin
c
      curchn = '#'
      curres = '#########'
      iat = 0
      ires = 0
      ich  = 0
c
c     the window width must be an odd number
      winwid = 5
      hwin = winwid/2
c
c-----read the pdb coordinates and set up the chain and reside indexing
c
 1000 read(5,5000,end=1100) line
      if (line(1:4) .eq. 'ATOM') then
         iat = iat + 1
         if (line(22:22) .ne. curchn) then
            ich = ich + 1
            ichf(ich) = iat
            if (ich .ne. 1) then
               ichl(ich-1) = iat - 1
               iresl(ires,ich-1) = iat - 1
            endif
            curchn = line(22:22)
            ichtyp(ich) = curchn
            ires = 0
         endif
         if (line(18:26) .ne. curres) then
            ires = ires + 1
            iresf(ires,ich) = iat
            if (ires .ne. 1) then
               iresl(ires-1,ich) = iat - 1
            endif
            curres = line(18:26)
            nrspch(ich) = ires
         endif
         pdb(iat,ich) = line
         isrec(iat,ich) = 1
      endif
      goto 1000
 1100 continue
      iresl(ires,ich) = iat 
      nch = ich
      nat = iat
c
      write(6,*) 'nch ',nch,' nat ',nat
c
      open(unit=9,file='all_windows.txt',form='formatted',
     1     status='unknown')
c
      do 100 ich=1,nch
         nres = nrspch(ich)
         nwin = nres - 2*hwin
         do 110 iw=1,nwin
            jat = iresf(iw,ich)
            kat = iresl(iw+2*hwin,ich)
            awin(1:5) = pdb(jat,ich)(22:26)
            awin(6:6) = '~'
            awin(7:11) = pdb(kat,ich)(22:26)
            do 111 i=1,11
               if(awin(i:i) .eq. ' ') awin(i:i) = '_'
 111        continue
            write(9,6000) ich,iw,iw+2*hwin,awin
 110     continue
 100  continue
c
c
      do 10 ich=1,nch
         write(6,*) nrspch(ich),' residues in chain',ich,' first atom '
     1   ,iresf(1,ich),' last atom ',iresl(nrspch(ich),ich),' chn ',
     2    ichtyp(ich)
 10   continue
c
c-----write headers and then the rest of the mol2 and pdb data
      STOP
c
 5000 format(a80)
 6000 format(3i6,'   ',a11,'   ')
c
      end
c
c
