c
c-----derived from bude_scan.f, bude_scan_inter.f chucks away the rest
c     of the structure in the window's chain (ie - just calculating the 
c     intermolecular energy tather than intra+inter as per bude_scan.f)
c
c     bude_scan reads a window from the file win_range.txt
c     a pdb structure from the command line (of the clathrin structure)
c     a mol2 file from the filename "mol2-format" which MUST be a babel
c     conversion of the pdb file
c     it produces the files receptor.mol2 and ligand.mol2 for the 
c     bude -f single_energy.inp calculation of the window energy
c     NB the N terminal N and C-terminal C of the window (ligand)
c     backbone are excluded...
c
      integer MXATPC,MXCHN,MXRES
      parameter(MXATPC=20000,MXCHN=20,MXRES=2000)
      character*80 pdb(MXATPC,MXCHN),line,curchn*1,curres*9,
     1 ichtyp(MXCHN)*1,mol2(MXATPC*MXCHN),header(1000),shift*24
      integer ichf(MXCHN),ichl(MXCHN),iresf(MXRES,MXCHN),
     1 iresl(MXRES,MXCHN),nrspch(MXCHN),isrec(MXATPC,MXCHN)
c
      curchn = '#'
      curres = '#########'
      iat = 0
      ires = 0
      ich  = 0
c
c-----read the pdb coordinates and set up the chain and reside indexing
c
 1000 read(5,5000,end=1100) line
C      write(6,*) 'iat = ',iat
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
C            write(6,*) 'ires ',ires,' ich ',ich,' nrspch ',nrspch(ich)
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
c-----read the mol2 header and atom data (expecting a babel mol2 version
c     of the pdb file here - either called, or linked to, "mol2-format")
      open(unit=4,file='mol2-format',form='formatted', 
     1 status='old')
      im = 0
 1200 read(4,5000,end=999) line
        im = im + 1
        header(im) = line
        if (line(1:17) .eq. '@<TRIPOS>MOLECULE') then
           imol = im 
        endif
        if (line(1:13) .eq. '@<TRIPOS>ATOM') then
           goto 1400 
        endif
      goto 1200
 1300 continue
 1400 continue
      nhead = im
c     format i6 OK for this but NOT GENERAL!
      read(header(imol+2),fmt='(i6)') nmol2
c     sanity check
      if (nmol2 .ne. nat) STOP 'ERROR - mismatch between pdb and mol2'
c
c-----ensure there is a gap between atom type and residue label in the
c     mol2 (babel does not guarantee this)
      do 15 jat=1,nmol2
         read(4,5000) mol2(jat)
         shift = mol2(jat)(53:76)
         mol2(jat)(53:53) = ' '
         mol2(jat)(54:77) = shift
 15   continue
c
      do 10 ich=1,nch
         write(6,*) nrspch(ich),' residues in chain',ich,' first atom '
     1   ,iresf(1,ich),' last atom ',iresl(nrspch(ich),ich),' chn ',
     2    ichtyp(ich)
 10   continue
c
      open(unit=1,file='win_range.txt',form='formatted',status='old')
      read(1,*) jchn,j1,j2
      write(6,*) 'Chain ',jchn,' first ',j1,' last ',j2
c
c-----exclude all the atoms of the ligand chain from the receptor
      do 80 ires=1,nrspch(jchn)
         do 90 iat=iresf(ires,jchn),iresl(ires,jchn)
            isrec(iat,jchn) = -1
 90      continue
 80   continue
c
c-----now select the "ligand" set of atoms comprising the window
c     flag the "ligand" set of atoms as 0 (via isrec)
      do 100 ires=j1,j2
         do 110 iat=iresf(ires,jchn),iresl(ires,jchn)
             isrec(iat,jchn) = 0
c------------Now no need to exclude the backbone peptide connection at each end of the
c            window
C             if (ires .eq. j1 .and. pdb(iat,jchn)(14:15) .eq. 'N ') 
C     1       isrec(iat,jchn) = -1
C             if (ires .eq. j2 .and. pdb(iat,jchn)(14:15) .eq. 'C ') 
C     1       isrec(iat,jchn) = -1
 110     continue
 100  continue
c
      open(unit=2,file='tmp/receptor.pdb',form='formatted',
     1 status='unknown')
      open(unit=3,file='tmp/ligand.pdb',form='formatted',
     1 status='unknown')
      open(unit=12,file='tmp/receptor.mol2',form='formatted', 
     1 status='unknown')
      open(unit=13,file='tmp/ligand.mol2',form='formatted',
     1 status='unknown')
c
c-----count how many atoms in each set
c
      nrec = 0
      nlig = 0
      do 200 ich=1,nch
         do 210 ires=1,nrspch(ich)
            do 220 iat=iresf(ires,ich),iresl(ires,ich)
               if (isrec(iat,ich) .eq. 1) then
                  nrec = nrec + 1
               else
                  nlig = nlig + 1
               endif
 220        continue
 210     continue
 200  continue
c
c-----write headers and then the rest of the mol2 and pdb data
      do 250 im=1,nhead
         if (im .eq. imol+2) then
            write(12,6000) nrec 
            write(13,6000) nlig 
         else
            write(12,5000) header(im) 
            write(13,5000) header(im) 
         endif
 250  continue
c
      jat = 0
      do 201 ich=1,nch
         do 211 ires=1,nrspch(ich)
            do 221 iat=iresf(ires,ich),iresl(ires,ich)
               jat = jat + 1
               if (isrec(iat,ich) .eq. 1) then
                   write(2,5000) pdb(iat,ich)
                   write(12,5000) mol2(jat)
               elseif (isrec(iat,ich) .eq. 0) then
                   write(3,5000) pdb(iat,ich)
                   write(13,5000) mol2(jat)
               else
                   write(6,*) 'Excluded: ',pdb(iat,ich)
               endif
 221        continue
 211     continue
 201  continue
c
      close(1)
      close(2)
      close(12)
      close(3)
      close(13)
c
      STOP
 999  STOP 'ERROR - in mol2 read'
c
 5000 format(a80)
 6000 format(i6,' 0 0 0 0')
c
      end
c
c
