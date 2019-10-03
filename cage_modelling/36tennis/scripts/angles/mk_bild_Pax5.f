c
c     This version finds the leg hinge-points by calculating
c     the midpoint of the closest approach of subsequent 3rd 
c     principal axes...        
c
      character*80 pdb(1000),line,mat(4,100),oldlin
      real thrdpa(3,100),ang(100),getang,dotp,xl(3,100)
c
      iseg = 0
      imat = 0
 1000 read(5,5000,end=1100) line
        if (index(line,'Inertia axes') .ne. 0) then
           imat = imat + 1
        endif
        if (index(line,'v1 =') .ne. 0) then
           mat(1,imat) = line
        endif
        if (index(line,'v2 =') .ne. 0) then
           mat(2,imat) = line
        endif
        if (index(line,'v3 =') .ne. 0) then
           mat(3,imat) = line
        endif
        if (index(line,'Centre of mass') .ne. 0) then
           mat(4,imat) = line
        endif
        if (index(line,'ENDMDL') .ne. 0) then
           iseg = iseg + 1
           if (oldlin(1:4) .ne. 'ATOM') then
              write(6,*) 'Must have a valid ATOM record preceding ',
     1        'each ENDMDL record'
              STOP 'ERROR in coordinate read'
           endif
           read(oldlin(31:54),fmt='(3f8.3)') (xl(ix,iseg),ix=1,3)
        endif
        oldlin = line
        goto 1000
 1100 continue
      nmat = imat
      nseg = iseg
c
      if (nmat .lt. nseg) then
         write(6,*) 'WARNING -- more segmnents than matrices provided'
         write(6,*) 'nmat ',nmat,'  nseg ',nseg
      elseif (nmat .gt. nseg) then
         write(6,*) 'WARNING -- fewer segmnents than matrices provided'
         write(6,*) 'nmat ',nmat,'  nseg ',nseg
      endif
c
C      write(6,*) 'nmat ',nmat,'  nseg ',nseg
c
      call mkbild(mat,nmat,thrdpa,xl)
c
c     get the angles between the series of 1 to nmat third principle axes
      do 20 im=1,nmat-1
         ang(im) = getang(thrdpa(1,im),thrdpa(1,im+1))
 20   continue
c
      write(6,6000)
      write(6,6010) (ang(im),im=1,nmat-1)
c
      STOP
c
 5000 format(a80)
 6000 format('DOMAINS:  1 -> 2   2 -> 3   3 -> 4   4 -> 5   5 -> 6 ')  
C 6000 format(' 1 -> 2   2 -> 3   3 -> 4   4 -> 5   5 -> 6   6 -> 7')  
 6010 format('ANGLES:  ',6(f7.2,2x))
c
      end
c
c 
      subroutine mkbild(mat,nmat,thrdpa,xl)         
c
      character*80 pdb(1000),line,mat(4,100),cols(2,100)*16
      real pax(3,3),rmat(3,3),d(3),thrdpa(3,100),getang,allpax(3,6,100),
     1 cx(3,100),xl(3,100),hinge(3,100),xleg(3,2,100),v1(3),v2(3),v3(3),
     2 v4(3),legang(100),dis,legdis(100),legtor(100)
c
      cols(1,1) = 'dark green      '
      cols(2,1) = 'hot pink        '
      cols(1,2) = 'navy blue       '
      cols(2,2) = 'cornflower blue '
      cols(1,3) = 'dark red        '
      cols(2,3) = 'orange          '
      scal = 4.0
c
c-----open the bild file
      open (unit=1,file='paxes.bild',form='formatted',status='unknown')
c
      do 10 imat=1,nmat
         read(mat(4,imat)(22:50),*) (cx(ix,imat),ix=1,3)
         do 20 il=1,3
            read(mat(il,imat)(13:51),fmt='(3f8.4,7x,f8.3)')
     1      (rmat(il,ix),ix=1,3),d(il)
C            write(6,6010) mat(il,imat)
C            write(6,6000) (rmat(il,ix),ix=1,3),d(il)
 20      continue
c
c        transpose the matix because Chimera has it reported wrongly 
         call transp(rmat)
c        save the third (minor) principle axis
         thrdpa(1,imat) = rmat(3,1)
         thrdpa(2,imat) = rmat(3,2)
         thrdpa(3,imat) = rmat(3,3)
c              
         do 30 il=1,3
c           get the tip of the axes in positive direction
            x = rmat(il,1)*scal*d(il) + cx(1,imat)
            y = rmat(il,2)*scal*d(il) + cx(2,imat)
            z = rmat(il,3)*scal*d(il) + cx(3,imat)
            allpax(il,1,imat) = x
            allpax(il,2,imat) = y
            allpax(il,3,imat) = z
c           get the tip of the axes in negative direction
            x = cx(1,imat) - rmat(il,1)*scal*d(il)
            y = cx(2,imat) - rmat(il,2)*scal*d(il) 
            z = cx(3,imat) - rmat(il,3)*scal*d(il) 
            allpax(il,4,imat) = x
            allpax(il,5,imat) = y
            allpax(il,6,imat) = z
 30      continue
C         write(6,6030) cols(1,il)
C         write(6,6040) cx,cy,cz,x,y,z
C         write(6,6010) mat(4,imat)
C         write(6,6020) cx,cy,cz
c
c     Now we figure out whether we need to swap the axes (pos for neg)
c     for each set of Paxes. If so, do it
 10   continue
c
      do 100 imat=1,nmat
C         write(6,*) 'Terminal coordinates ',(xl(ix,imat),ix=1,3)
         dp = dist(allpax,xl,imat,3,1)
         dn = dist(allpax,xl,imat,3,4)
C         write(6,*) 'dp ',dp,' dn ',dn,' imat ',imat,' ip ',
C     1     ' dp-dn ',dp-dn
         if (dn .lt. dp) then
            call swap(allpax,imat,3,thrdpa)
         endif
 100  continue
c
c     write the vectors for the bild file axes
      do 200 imat=1,nmat
         do 40 il=1,3
            write(1,6030) cols(1,il)
            write(1,6040)(cx(ix,imat),ix=1,3),
     1      (allpax(il,ix,imat),ix=1,3)
            write(1,6030) cols(2,il)
            write(1,6040)(cx(ix,imat),ix=1,3),
     1      (allpax(il,ix,imat),ix=4,6)
 40      continue
 200  continue
c
C         write(6,*) 
C     1   'VEC',imat,' : ', pax(3,1)-cx, pax(3,2)-cy, pax(3,3)-cz       
c         
c     Now we calculate the midpoint of the closest approach of
c     subsequent third PAs to get the leg hinge points. Then connect
c     these up to give a stick model (bild) of the legs plus associated 
c     geometric data.
c
      open(unit=2,file='legs.bild',form='formatted',status='unknown')
      open(unit=3,file='legs.pdb',form='formatted',status='unknown')
c
      do 300 imat=1,nmat-1
         ivec = imat
         call getmdp(ivec,cx,thrdpa,hinge)
 300  continue
c
      do 310 ip=1,nmat
         if (ip .eq. 1) then
            do 320 ix=1,3
               xleg(ix,1,ip) = cx(ix,ip)
               xleg(ix,2,ip) = hinge(ix,ip)
 320        continue
         elseif (ip .eq. nmat) then
            do 330 ix=1,3
               xleg(ix,1,ip) = hinge(ix,ip-1)
               xleg(ix,2,ip) = cx(ix,ip)
 330        continue
         else
            do 340 ix=1,3
               xleg(ix,1,ip) = hinge(ix,ip-1)
               xleg(ix,2,ip) = hinge(ix,ip)
 340        continue
         endif
 310  continue
c
c     and construct the leg bild object
c
      rad = 1.0
      write(2,6100)
c
      do 350 ip=1,nmat
         write(2,6110) (xleg(ix,1,ip),ix=1,3),rad
         write(2,6110) (xleg(ix,2,ip),ix=1,3),rad
         write(2,6120) (xleg(ix,1,ip),ix=1,3),(xleg(ix,2,ip),ix=1,3),rad
         write(3,6130) ip,(xleg(ix,1,ip),ix=1,3)
         if (ip .eq. nmat) write(3,6130) ip,(xleg(ix,2,ip),ix=1,3)
 350  continue
c
c     measure the angles
c
      do 360 ip=1,nmat
         do 370 ix=1,3
            v1(ix) = xleg(ix,1,ip)
            v2(ix) = xleg(ix,2,ip)
 370     continue
         legdis(ip) = dis(v1,v2)
         if (ip .lt. nmat) then
            do 380 ix=1,3
               v1(ix) = xleg(ix,2,ip) - xleg(ix,1,ip)
               v2(ix) = xleg(ix,2,ip+1) - xleg(ix,2,ip)
 380        continue  
            legang(ip) = getang(v1,v2)
         endif
         if (ip .lt. nmat-1) then
            do 390 ix=1,3
               v1(ix) = xleg(ix,2,ip) - xleg(ix,1,ip)
               v2(ix) = xleg(ix,2,ip+1) - xleg(ix,2,ip)
               v3(ix) = xleg(ix,2,ip+2) - xleg(ix,2,ip+1)
 390        continue
            legtor(ip) = gettor(v1,v2,v3)
         endif
 360  continue
c
c     write out the leg data:
c
      write(6,6200) (legdis(ix),ix=1,5)
      write(6,6210) (legang(ix),ix=1,4)
      write(6,6220) (legtor(ix),ix=1,3)
c
      close (1)
      close (2)
      close (3)
c
      return
c 
 6000 format(4f10.4)
 6010 format(a80)
 6020 format(3f10.4)
 6030 format('.color ',a16)
 6040 format('.arrow ',6f10.3,' 0.2 1.0')
c
 6100 format('.color green')
 6110 format('.sphere ',4f10.3)
 6120 format('.cylinder ',7f10.3)
 6130 format('ATOM      1  CA  LEG     ',i1,'    ',3f8.3,
     1'  1.00 00.00           C  ')
c
 6200 format('LEG_LENGTHS: ',5f8.2)
 6210 format('LEG_ANGLES:  ',4f8.2)
 6220 format('LEG_TORSIONS:',3f8.2)
c
c
      end
c
c
      real function dist(allpax,xl,imat,ip,j)
c
      real allpax(3,6,100),xl(3,100)
c
      dist = sqrt((allpax(ip,j,imat)-xl(1,imat))**2 +
     1 (allpax(ip,j+1,imat)-xl(2,imat))**2 +
     1 (allpax(ip,j+2,imat)-xl(3,imat))**2 )
c
C      write(6,*)'ip,j,imat,dist  ',ip,j,imat,dist
c
      return
c
      end
c
c
      real function dis(a,b)
c
      real a(3),b(3)
c
      dis = sqrt((a(1)-b(1))**2 + (a(2)-b(2))**2 + (a(3)-b(3))**2)
c
      return
c
      end
c
c
      subroutine swap(allpax,imat,ip,thrdpa) 
c
      real allpax(3,6,100),thrdpa(3,100)
c
      write(6,*) 'SWAPPING: imat = ',imat,' ip = ',ip
      do 10 il=1,3
c
         xp = allpax(il,1,imat)
         yp = allpax(il,2,imat)
         zp = allpax(il,3,imat)
         xn = allpax(il,4,imat)
         yn = allpax(il,5,imat)
         zn = allpax(il,6,imat)
c
         allpax(il,1,imat) = xn
         allpax(il,2,imat) = yn
         allpax(il,3,imat) = zn
         allpax(il,4,imat) = xp
         allpax(il,5,imat) = yp
         allpax(il,6,imat) = zp
c
         xt = thrdpa(1,imat)
         yt = thrdpa(2,imat)
         zt = thrdpa(3,imat)
c
         thrdpa(1,imat) = -xt
         thrdpa(2,imat) = -yt
         thrdpa(3,imat) = -zt
c
 10   continue
c
      return
c
      end
c
c
      subroutine transp(rmat)
c
c-----transpose a 3x3 matrix
c
      real rmat(3,3),tmat(3,3)
c
      do 10 i=1,3
         do 20 j=1,3
            tmat(j,i) = rmat(i,j)
 20      continue
 10   continue
c
      do 30 i=1,3
         do 40 j=1,3
            rmat(i,j) = tmat(i,j)
 40      continue
 30   continue
c
      return
c
      end
c
c
      real function getang(v1,v2)
c
c-----angle betwen 2 vectors in degrees
c
      real v1(3),v2(3),dotp
c
      call norm(v1)
      call norm(v2)
c
      dp = dotp(v1,v2)
      getang = acos(dp)*57.2958
c
      return
c
      end
c
c
      subroutine norm(v)
c
c-----Normalize a vector
c
      real v(3),d
c
      d = sqrt(v(1)**2 + v(2)**2 + v(3)**2)
c
      do 10 ix=1,3
         v(ix) = v(ix)/d
 10   continue
c
      return
c
      end
c
c
      real function dotp(v1,v2)
c
c-----Dot product of two vectors
c
      real v1(3),v2(3)
c
      dotp = v1(1)*v2(1) + v1(2)*v2(2) + v1(3)*v2(3)
c
      return
c
      end
c
c
      subroutine getmdp(ivec,cx,thrdpa,hinge)
c
c     see document Distance_between_Skew_Lines.docx
c
      real thrdpa(3,100),cx(3,100),hinge(3,100),po(3),qo(3),u(3),v(3),
     1 wo(3),a,b,c,d,e,dotp,sc,tc,denom,small,pc(3),qc(3)
c
      small = 0.00001
c
      do 10 ix=1,3
         po(ix) = cx(ix,ivec)      
         qo(ix) = cx(ix,ivec+1) 
         u(ix) = thrdpa(ix,ivec)      
         v(ix) = thrdpa(ix,ivec+1)
         wo(ix) = po(ix) - qo(ix)
 10   continue
c 
      a = dotp(u,u)
      b = dotp(u,v)
      c = dotp(v,v)
      d = dotp(u,wo)
      e = dotp(v,wo)
c
      denom = a*c - b*b
c
      if (abs(denom) .lt. small) STOP 'Lines are parallel!'
c
      sc = (b*e - c*d)/denom
      tc = (a*e - b*d)/denom
c
      do 20 ix=1,3
         pc(ix) = po(ix) + sc*u(ix)
         qc(ix) = qo(ix) + tc*v(ix)
         hinge(ix,ivec) = (pc(ix) + qc(ix))/2.0000
 20   continue
c
      return
c
      end
c
c
c
      real function gettor(b1,b2,b3)
c
      real b1(3),b2(3),b3(3),n1(3),n2(3),m1(3),dotp
c   
C      call norm(b1)
C      call norm(b2)
C      call norm(b3)
c
      call crosp(n1,b1,b2)
      call crosp(n2,b2,b3)
c
C      call norm(n1)
C      call norm(n2)
c
      call crosp(m1,n1,n2)
c
      x = dotp(n1,n2)
      call norm(b2)
      y = dotp(m1,b2)
      z = dotp(b2,n2)
c
      if (abs(z) .gt. 0.01) then
         write(6,*) 'WARNING |Z| > 0.01, it is ',z
      endif
c
      gettor = atan2(y,x)*57.295
c
      return
c
      end
c
c
      subroutine crosp(a,b,c)
c
      real a(3),b(3),c(3)
c
      a(1) = b(2)*c(3) - b(3)*c(2)
      a(2) = b(3)*c(1) - b(1)*c(3)
      a(3) = b(1)*c(2) - b(2)*c(1)
c
      return
c
      end
c
c

