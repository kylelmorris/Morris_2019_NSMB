c
      character*80 pdb(1000),line,mat(4,100)
      real thrdpa(3,100),ang(100),getang,dotp
c
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
        if (index(line,'MODEL') .ne. 0) goto 1100
        goto 1000
 1100 continue
      nmat = imat
c
C      write(6,*) 'nmat ',nmat
c
c
      do 10 imat=1,nmat
         call mkbild(mat,nmat,thrdpa)
 10   continue
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
      subroutine mkbild(mat,nmat,thrdpa)         
c
      character*80 pdb(1000),line,mat(4,100),cols(2,100)*16
      real pax(3,3),rmat(3,3),d(3),thrdpa(3,100),getang
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
         read(mat(4,imat)(22:50),*) cx,cy,cz
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
            x = rmat(il,1)*scal*d(il) + cx
            y = rmat(il,2)*scal*d(il) + cy
            z = rmat(il,3)*scal*d(il) + cz
            pax(il,1) = x
            pax(il,2) = y
            pax(il,3) = z
 30      continue
C         write(6,6030) cols(1,il)
C         write(6,6040) cx,cy,cz,x,y,z
C         write(6,6010) mat(4,imat)
C         write(6,6020) cx,cy,cz
c
         do 40 il=1,3
            write(1,6030) cols(1,il)
            write(1,6040) cx,cy,cz,pax(il,1),pax(il,2),pax(il,3)
 40      continue
c
C         write(6,*) 
C     1   'VEC',imat,' : ', pax(3,1)-cx, pax(3,2)-cy, pax(3,3)-cz       
c         
 10   continue
c
      close (1)
c
      return
c 
 6000 format(4f10.4)
 6010 format(a80)
 6020 format(3f10.4)
 6030 format('.color ',a16)
 6040 format('.arrow ',6f10.3,' 0.2 1.0')
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
c
      
