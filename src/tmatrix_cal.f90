!   ICHOICE=1  NCHECK=1
!   RAT= .963711
!   PROLATE SPHEROIDS, A/B=   .5000000
!   LAM=  6.283185   MRR= .1500D+01   MRI= .2000D-01
!   ACCURACY OF COMPUTATIONS DDELT =  .10D-02
!   EQUAL-SURFACE-AREA-SPHERE RADIUS= 10.0000
!   thet0= 56.00  thet= 65.00  phi0=114.00  phi=128.00  alpha=145.00  beta= 52.00
!   AMPLITUDE MATRIX
!   S11=-.50941D+01 + i* .24402D+02
!   S12=-.19425D+01 + i* .19971D+01
!   S21=-.11521D+01 + i*-.30977D+01
!   S22=-.69323D+01 + i* .24748D+02
!   PHASE MATRIX
!     650.3172  -17.9846   10.0498  -12.7580
!     -21.1462  631.6322 -127.3059   87.2144
!       6.8322  132.6131  635.2767  -34.7730
!      -9.6629  -78.1229   51.4094  643.1738
!    time =     .03 min

!   New release including the LAPACK matrix inversion procedure.
!   We thank Cory Davis (University of Edinburgh) for pointing
!   out the possibility of replacing the proprietary NAG matrix
!   inversion routine by the public-domain LAPACK equivalent.

!   CALCULATION OF THE AMPLITUDE AND PHASE MATRICES FOR
!   A PARTICLE WITH AN AXIALLY SYMMETRIC SHAPE
                                                                       
!   This version of the code uses DOUBLE PRECISION variables,
!   is applicable to spheroids, finite circular cylinders,
!   Chebyshev particles, and generalized Chebyshev particles
!   (distorted water drops), and must be used along with the
!   accompanying files lpd.f and ampld.par.f.
                                                                       
!   Last update 08/06/2005
                                                                       
!   The code has been developed by Michael Mishchenko at the NASA
!   Goddard Institute for Space Studies, New York.  The development
!   of the code was supported by the NASA Radiation Sciences Program.

!   The code can be used without limitations in any not-for-
!   profit scientific research.  We only request that in any
!   publication using the code the source of the code be acknowledged
!   and relevant references (see below) be made.

!   The computational method is based on the T-matrix approach
!   [P. C. Waterman, Phys. Rev. D 3, 825 (1971)], also known as
!   the extended boundary condition method.  The method was
!   improved in the following papers:

!   1.  M. I. Mishchenko and L. D. Travis, T-matrix computations
!       of light scattering by large spheroidal particles,
!       Opt. Commun., vol. 109, 16-21 (1994).
!
!   2.  M. I. Mishchenko, L. D. Travis, and A. Macke, Scattering
!       of light by polydisperse, randomly oriented, finite
!       circular cylinders, Appl. Opt., vol. 35, 4927-4940 (1996).
!
!   3.  D. J. Wielaard, M. I. Mishchenko, A. Macke, and B. E. Carlson,
!       Improved T-matrix computations for large, nonabsorbing and
!       weakly absorbing nonspherical particles and comparison
!       with geometrical optics approximation, Appl. Opt., vol. 36,
!       4305-4313 (1997).
!
!   A general review of the T-matrix approach can be found in
!
!   4.  M. I. Mishchenko, L. D. Travis, and D. W. Mackowski,
!       T-matrix computations of light scattering by nonspherical
!       particles:  a review, J. Quant. Spectrosc. Radiat.
!       Transfer, vol. 55, 535-575 (1996).
!
!   Additional useful information is contained in the paper
!
!   5.  M. I. Mishchenko and L. D. Travis, Capabilities and
!       limitations of a current FORTRAN implementation of the
!       T-matrix method for randomly oriented, rotationally
!       symmetric scatterers, J. Quant. Spectrosc. Radiat. Transfer,
!       vol. 60, 309-324 (1998).
!
!   The definitions and notation used can also be found in
!
!   6.  M. I. Mishchenko, Calculation of the amplitude matrix
!       for a nonspherical particle in a fixed orientation,
!       Appl. Opt. vol. 39, 1026-1031 (2000).

!   These papers are available in the .pdf format at the web site
!
!   http://www.giss.nasa.gov/~crmim/publications/
!
!   or in hardcopy upon request from Michael Mishchenko
!   Please e-mail your request to crmim@giss.nasa.gov.
!
!   A comprehensive book "Scattering, Absorption, and Emission of
!   Light by Small Particles" (Cambridge University Press, Cambridge,
!   2002) is also available in the .pdf format at the web site
!
!   http://www.giss.nasa.gov/~crmim/books.html

!   One of the main advantages of the T-matrix method is that the
!   T-matrix for a given nonspherical particle needs to be computed
!   only once and then can be used any number of times for computing
!   the amplitude and phase matrices for any directions of the incident
!   and scattered beams.  This makes the T-matrix method
!   extremely convenient and efficient in averaging over particle
!   orientations and/or directions of incidence (or scattering).
                                                                       
!   The use of extended precision variables (Ref. 1) can significantly
!   increase the maximum convergent equivalent-sphere size parameter
!   and make it well larger than 100 (depending on refractive index
!   and aspect ratio).  The extended-precision code is also available.
!   However, the use of extended precision variables results in a
!   greater consumption of CPU time.
!   On IBM RISC workstations, that code is approximately
!   five times slower than this double-precision code.  The
!   CPU time difference between the double-precision and extended-
!   precision codes can be larger on supercomputers.
                                                                       
!   This is the first part of the full T-matrix code.  The second part,
!   lpq.f, is completely independent of the first part. It contains no
!   T-matrix-specific subroutines and can be compiled separately.
!   The second part of the code replaces the previously implemented
!   standard matrix inversion scheme based on Gaussian elimination
!   by a scheme based on the LU factorization technique.
!   As described in Ref. 3 above, the use of the LU factorization is
!   especially beneficial for nonabsorbing or weakly absorbing particles.
!   In this code we use the LAPACK implementation of the LU factorization
!   scheme. LAPACK stands for Linear Algebra PACKage. The latter is
!   publicly available at the following internet site:
!
!   http://www.netlib.org/lapack/
 
                                                                       
!   INPUT PARAMETERS:
!
!      AXI - equivalent-sphere radius
!      RAT = 1 - particle size is specified in terms of the
!                equal-volume-sphere radius
!      RAT.ne.1 - particle size is specified in terms of the
!                equal-surface-area-sphere radius
!      LAM - WAVELENGTH OF INCIDENT LIGHT
!      MRR and MRI - real and imaginary parts of the refractive
!                  index
!      EPS and NP - specify the shape of the particles.
!             For spheroids NP=-1 and EPS is the ratio of the
!                 horizontal to rotational axes.  EPS is larger than
!                 1 for oblate spheroids and smaller than 1 for
!                 prolate spheroids.
!             For cylinders NP=-2 and EPS is the ratio of the
!                 diameter to the length.
!             For Chebyshev particles NP must be positive and
!                 is the degree of the Chebyshev polynomial, while
!                 EPS is the deformation parameter (Ref. 5).
!             For generalized Chebyshev particles (describing the shape
!                 of distorted water drops) NP=-3.  The coefficients
!                 of the Chebyshev polynomial expansion of the particle
!                 shape (Ref. 7) are specified in subroutine DROP.
!      DDELT - accuracy of the computations
!      NDGS - parameter controlling the number of division points
!             in computing integrals over the particle surface (Ref. 5).
!             For compact particles, the recommended value is 2.
!             For highly aspherical particles larger values (3, 4,...)
!             may be necessary to obtain convergence.
!             The code does not check convergence over this parameter.
!             Therefore, control comparisons of results obtained with
!             different NDGS-values are recommended.
!      ALPHA and BETA - Euler angles (in degrees) specifying the orientation
!            of the scattering particle relative to the laboratory reference
!            frame (Refs. 6 and 7).
!      THET0 - zenith angle of the incident beam in degrees
!      THET - zenith angle of the scattered beam in degrees
!      PHI0 - azimuth angle of the incident beam in degrees
!      PHI - azimuth angle of the scattered beam in degrees
!            (Refs. 6 and 7)
!      ALPHA, BETA, THET0, THET, PHI0, and PHI are specified at the end of
!      the main program before the line
!
!       "CALL AMPL (NMAX,...)"
!
!      The part of the main program following the line
!
!       "COMPUTATION OF THE AMPLITUDE AND PHASE MATRICES"
!
!      can be repeated any number of times.  At this point the T-matrix
!      for the given scattering particle has already
!      been fully computed and can be repeatedly used in computations
!      for any directions of illumination and scattering and any particle
!      orientations.
                                                                       
!   OUTPUT PARAMETERS:
!
!      Elements of the 2x2 amplitude matrix
!      Elements of the 4x4 phase matrix
                                                                       
!   Note that LAM and AXI must be given in the same units of length
!   (e.g., microns).
                                                                       
!   The convergence of the T-matrix method for particles with
!   different sizes, refractive indices, and aspect ratios can be
!   dramatically different.  Usually, large sizes and large aspect
!   ratios cause problems.  The user of this code
!   should "play" a little with different input parameters in
!   order to get an idea of the range of applicability of this
!   technique.  Sometimes decreasing the aspect ratio
!   from 3 to 2 can increase the maximum convergent equivalent-
!   sphere size parameter by a factor of several.
                                                                       
!   The CPU time required rapidly increases with increasing ratio
!   radius/wavelength and/or with increasing particle asphericity.
!   This should be taken into account in planning massive computations.
                                                                       
!   Execution can be automatically terminated if dimensions of certain
!   arrays are not big enough or if the convergence procedure decides
!   that the accuracy of double-precision variables is insufficient
!   to obtain a converged T-matrix solution for given particles.
!   In all cases, a message appears explaining
!   the cause of termination.
                                                                       
!   The message
!        "WARNING:  W IS GREATER THAN 1"
!   means that the single-scattering albedo exceeds the maximum
!   possible value 1.  If W is greater than 1 by more than
!   DDELT, this message can be an indication of numerical
!   instability caused by extreme values of particle parameters.
                                                                       
!   The message "WARNING: NGAUSS=NPNG1" means that convergence over
!   the parameter NG (see Ref. 2) cannot be obtained for the NPNG1
!   value specified in the PARAMETER statement in the file ampld.par.f.
!   Often this is not a serious problem, especially for compact
!   particles.
                                                                       
!   Larger and/or more aspherical particles may require larger
!   values of the parameters NPN1, NPN4, and NPNG1 in the file
!   ampld.par.f.  It is recommended to keep NPN1=NPN4+25 and
!   NPNG1=3*NPN1.  Note that the memory requirement increases
!   as the third power of NPN4. If the memory of
!   a computer is too small to accomodate the code in its current
!   setting, the parameters NPN1, NPN4, and NPNG1 should be
!   decreased. However, this will decrease the maximum size parameter
!   that can be handled by the code.

!   In some cases any increases of NPN1 will not make the T-matrix
!   computations convergent.  This means that the particle is just
!   too "bad" (extreme size parameter and/or extreme aspect ratio
!   and/or extreme refractive index).
!   The main program contains several PRINT statements which are
!   currently commentd out.  If uncommented, these statements will
!   produce numbers which show the convergence rate and can be
!   used to determine whether T-matrix computations for given particle
!   parameters will converge at all, whatever the parameter NPN1 is.
                                                                       
!   Some of the common blocks are used to save memory rather than
!   to transfer data.  Therefore, if a compiler produces a warning
!   message that the lengths of a common block are different in
!   different subroutines, this is not a real problem.
                                                                       
!   The recommended value of DDELT is 0.001.  For bigger values,
!   false convergence can be obtained.
                                                                       
!   In computations for spheres, use EPS=1.000001 instead of EPS=1.
!   EPS=1 can cause overflows in some rare cases.
                                                                       
!   For some compilers, DACOS must be raplaced by DARCOS and DASIN
!   by DARSIN.
                                                                       
!   I would highly appreciate informing me of any problems encountered
!   with this code.  Please send your message to the following
!   e-mail address:  CRMIM@GISS.NASA.GOV.

!   WHILE THE COMPUTER PROGRAM HAS BEEN TESTED FOR A VARIETY OF CASES,
!   IT IS NOT INCONCEIVABLE THAT IT CONTAINS UNDETECTED ERRORS. ALSO,
!   INPUT PARAMETERS CAN BE USED WHICH ARE OUTSIDE THE ENVELOPE OF
!   VALUES FOR WHICH RESULTS ARE COMPUTED ACCURATELY. FOR THIS REASON,
!   THE AUTHORS AND THEIR ORGANIZATION DISCLAIM ALL LIABILITY FOR
!   ANY DAMAGES THAT MAY RESULT FROM THE USE OF THE PROGRAM.

SUBROUTINE TMATRIX_CAL(FREQ, SNOW_REF, AXI1, AS_RATIO, ALPHA, &
BETA, PHI0, THET0, PHI, THET, RAT, S11, S12, S21, S22)


    IMPLICIT REAL*8 (A-H,O-Z)
    !      INCLUDE 'ampld.par.f'

    Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1,&
    NPL=NPN2+1, NPN3=NPN1+1,&
    NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

    REAL*8  LAM,MRR,MRI,X(NPNG2),W(NPNG2),S(NPNG2),SS(NPNG2),&
    AN(NPN1),R(NPNG2),DR(NPNG2),&
    DDR(NPNG2),DRR(NPNG2),DRI(NPNG2),ANN(NPN1,NPN1)
    REAL*8 TR1(NPN2,NPN2),TI1(NPN2,NPN2)
    !      REAL*8 XALPHA(300),XBETA(300),WALPHA(300),WBETA(300)
    REAL*4&
    RT11(NPN6,NPN4,NPN4),RT12(NPN6,NPN4,NPN4),&
    RT21(NPN6,NPN4,NPN4),RT22(NPN6,NPN4,NPN4),&
    IT11(NPN6,NPN4,NPN4),IT12(NPN6,NPN4,NPN4),&
    IT21(NPN6,NPN4,NPN4),IT22(NPN6,NPN4,NPN4)
    COMPLEX*16 S11,S12,S21,S22
 
    COMMON /CT/ TR1,TI1
    COMMON /TMAT/ RT11,RT12,RT21,RT22,IT11,IT12,IT21,IT22
    COMMON /CHOICE/ ICHOICE

    !      REAL*8 MAX_DIM,MIN_MAX_RATIO,ICE_DENS,AIR_DENS,VOLM,MIN_DIM,
    !     &         MASS,ICE_REL_VOLM,TEMPR
    REAL*8 FREQ, AXI, AS_RATIO, ALPHA, BETA, PHI0, THET0, THET,&
    RAT,AXI1
    COMPLEX*16 SNOW_REF

    !      WRITE(*,*)'TMATRIX-CAL',FREQ, SNOW_REF, AXI, AS_RATIO,
    !     &     ALPHA, BETA, THETA, THETA0, PHI, PHI0

    ! CONVERT THE UNIT OF AXI AND LAM FROM METER TO MICROMETER
     
    AXI = AXI1*1E6
    LAM = 3.0E8/(FREQ)*1E6
    MRR = REAL(SNOW_REF)
    MRI = IMAG(SNOW_REF)
    MRI = ABS(MRI)
    EPS = 1./AS_RATIO
    NP = -1
    DDELT = 0.0001D0
    NDGS = 2
    RAT = 1

    P=DACOS(-1D0)
    NCHECK=0
    IF (NP.EQ.-1.OR.NP.EQ.-2) NCHECK=1
    IF (NP.GT.0.AND.(-1)**NP.EQ.1) NCHECK=1
    !      WRITE (6,5454) NCHECK
    ! 5454 FORMAT ('NCHECK=',I1)
    IF (DABS(RAT-1D0).GT.1D-8.AND.NP.EQ.-1) CALL SAREA (EPS,RAT)
    IF (DABS(RAT-1D0).GT.1D-8.AND.NP.GE.0) CALL SURFCH(NP,EPS,RAT)
    IF (DABS(RAT-1D0).GT.1D-8.AND.NP.EQ.-2) CALL SAREAC (EPS,RAT)
    IF (NP.EQ.-3) CALL DROP (RAT)
    !     PRINT 8000, RAT
    ! 8000 FORMAT ('RAT=',F12.6)
    !      IF(NP.EQ.-1.AND.EPS.GE.1D0) PRINT 7000,EPS
    !      IF(NP.EQ.-1.AND.EPS.LT.1D0) PRINT 7001,EPS
    !      IF(NP.GE.0) PRINT 7100,NP,EPS
    !      IF(NP.EQ.-2.AND.EPS.GE.1D0) PRINT 7150,EPS
    !      IF(NP.EQ.-2.AND.EPS.LT.1D0) PRINT 7151,EPS
    !      IF(NP.EQ.-3) PRINT 7160
    !      PRINT 7400, LAM,MRR,MRI
    !      PRINT 7200,DDELT
7000 FORMAT('OBLATE SPHEROIDS, A/B=',F11.7)
7001 FORMAT('PROLATE SPHEROIDS, A/B=',F11.7)
7100 FORMAT('CHEBYSHEV PARTICLES, T',&
    I1,'(',F5.2,')')
7150 FORMAT('OBLATE CYLINDERS, D/L=',F11.7)
7151 FORMAT('PROLATE CYLINDERS, D/L=',F11.7)
7160 FORMAT('GENERALIZED CHEBYSHEV PARTICLES')
7200 FORMAT ('ACCURACY OF COMPUTATIONS DDELT = ',D8.2)
7400 FORMAT('LAM=',F12.6,3X,'MRR=',D10.4,3X,'MRI=',D10.4)
    DDELT=0.1D0*DDELT
    !      IF (DABS(RAT-1D0).LE.1D-6) PRINT 8003, AXI
    !      IF (DABS(RAT-1D0).GT.1D-6) PRINT 8004, AXI
8003 FORMAT('EQUAL-VOLUME-SPHERE RADIUS=',F10.4)
8004 FORMAT('EQUAL-SURFACE-AREA-SPHERE RADIUS=',F10.4)
    A=RAT*AXI
    XEV=2D0*P*A/LAM
    IXXX=XEV+4.05D0*XEV**0.333333D0
    INM1=MAX0(4,IXXX)
    IF (INM1.GE.NPN1) PRINT 7333, NPN1
    IF (INM1.GE.NPN1) STOP
7333 FORMAT('CONVERGENCE IS NOT OBTAINED FOR NPN1=',I3, &
    '.  EXECUTION TERMINATED')
    QEXT1=0D0
    QSCA1=0D0
    DO 50 NMA=INM1,NPN1
        NMAX=NMA
        MMAX=1
        NGAUSS=NMAX*NDGS
        IF (NGAUSS.GT.NPNG1) PRINT 7340, NGAUSS
        IF (NGAUSS.GT.NPNG1) STOP
7340    FORMAT('NGAUSS =',I3,' I.E. IS GREATER THAN NPNG1.',&
        '  EXECUTION TERMINATED')
7334    FORMAT(' NMAX =', I3,'  DC2=',D8.2,'   DC1=',D8.2)
        CALL CONST(NGAUSS,NMAX,MMAX,P,X,W,AN,ANN,S,SS,NP,EPS)
        CALL VARY(LAM,MRR,MRI,A,EPS,NP,NGAUSS,X,P,PPI,PIR,PII,R,&
        DR,DDR,DRR,DRI,NMAX)
        CALL TMATR0 (NGAUSS,X,W,AN,ANN,S,SS,PPI,PIR,PII,R,DR,&
        DDR,DRR,DRI,NMAX,NCHECK)
        QEXT=0D0
        QSCA=0D0
        DO 4 N=1,NMAX
            N1=N+NMAX
            TR1NN=TR1(N,N)
            TI1NN=TI1(N,N)
            TR1NN1=TR1(N1,N1)
            TI1NN1=TI1(N1,N1)
            DN1=DFLOAT(2*N+1)
            QSCA=QSCA+DN1*(TR1NN*TR1NN+TI1NN*TI1NN&
            +TR1NN1*TR1NN1+TI1NN1*TI1NN1)
            QEXT=QEXT+(TR1NN+TR1NN1)*DN1
4       CONTINUE
        DSCA=DABS((QSCA1-QSCA)/QSCA)
        DEXT=DABS((QEXT1-QEXT)/QEXT)
        QEXT1=QEXT
        QSCA1=QSCA
        !        PRINT 7334, NMAX,DSCA,DEXT
        IF(DSCA.LE.DDELT.AND.DEXT.LE.DDELT) GO TO 55
        IF (NMA.EQ.NPN1) PRINT 7333, NPN1
        IF (NMA.EQ.NPN1) STOP
50  CONTINUE
55  NNNGGG=NGAUSS+1
    MMAX=NMAX
    IF (NGAUSS.EQ.NPNG1) PRINT 7336
    IF (NGAUSS.EQ.NPNG1) GO TO 155
    DO 150 NGAUS=NNNGGG,NPNG1
        NGAUSS=NGAUS
        NGGG=2*NGAUSS
7336    FORMAT('WARNING: NGAUSS=NPNG1')
7337    FORMAT(' NG=',I3,'  DC2=',D8.2,'   DC1=',D8.2)
        CALL CONST(NGAUSS,NMAX,MMAX,P,X,W,AN,ANN,S,SS,NP,EPS)
        CALL VARY(LAM,MRR,MRI,A,EPS,NP,NGAUSS,X,P,PPI,PIR,PII,R,&
        DR,DDR,DRR,DRI,NMAX)
        CALL TMATR0 (NGAUSS,X,W,AN,ANN,S,SS,PPI,PIR,PII,R,DR,&
        DDR,DRR,DRI,NMAX,NCHECK)
        QEXT=0D0
        QSCA=0D0
        DO 104 N=1,NMAX
            N1=N+NMAX
            TR1NN=TR1(N,N)
            TI1NN=TI1(N,N)
            TR1NN1=TR1(N1,N1)
            TI1NN1=TI1(N1,N1)
            DN1=DFLOAT(2*N+1)
            QSCA=QSCA+DN1*(TR1NN*TR1NN+TI1NN*TI1NN&
            +TR1NN1*TR1NN1+TI1NN1*TI1NN1)
            QEXT=QEXT+(TR1NN+TR1NN1)*DN1
104     CONTINUE
        DSCA=DABS((QSCA1-QSCA)/QSCA)
        DEXT=DABS((QEXT1-QEXT)/QEXT)
        !        PRINT 7337, NGGG,DSCA,DEXT
        QEXT1=QEXT
        QSCA1=QSCA
        IF(DSCA.LE.DDELT.AND.DEXT.LE.DDELT) GO TO 155
        IF (NGAUS.EQ.NPNG1) PRINT 7336
150 CONTINUE
155 CONTINUE
    QSCA=0D0
    QEXT=0D0
    NNM=NMAX*2
    DO 204 N=1,NNM
        QEXT=QEXT+TR1(N,N)
204 CONTINUE
    DO 213 N2=1,NMAX
        NN2=N2+NMAX
        DO 213 N1=1,NMAX
            NN1=N1+NMAX
            ZZ1=TR1(N1,N2)
            RT11(1,N1,N2)=ZZ1
            ZZ2=TI1(N1,N2)
            IT11(1,N1,N2)=ZZ2
            ZZ3=TR1(N1,NN2)
            RT12(1,N1,N2)=ZZ3
            ZZ4=TI1(N1,NN2)
            IT12(1,N1,N2)=ZZ4
            ZZ5=TR1(NN1,N2)
            RT21(1,N1,N2)=ZZ5
            ZZ6=TI1(NN1,N2)
            IT21(1,N1,N2)=ZZ6
            ZZ7=TR1(NN1,NN2)
            RT22(1,N1,N2)=ZZ7
            ZZ8=TI1(NN1,NN2)
            IT22(1,N1,N2)=ZZ8
            QSCA=QSCA+ZZ1*ZZ1+ZZ2*ZZ2+ZZ3*ZZ3+ZZ4*ZZ4&
            +ZZ5*ZZ5+ZZ6*ZZ6+ZZ7*ZZ7+ZZ8*ZZ8
213     CONTINUE
        !     PRINT 7800,0,DABS(QEXT),QSCA,NMAX
        DO 220 M=1,NMAX
            CALL TMATR(M,NGAUSS,X,W,AN,ANN,S,SS,PPI,PIR,PII,R,DR,&
            DDR,DRR,DRI,NMAX,NCHECK)
            NM=NMAX-M+1
            M1=M+1
            QSC=0D0
            DO 214 N2=1,NM
                NN2=N2+M-1
                N22=N2+NM
                DO 214 N1=1,NM
                    NN1=N1+M-1
                    N11=N1+NM
                    ZZ1=TR1(N1,N2)
                    RT11(M1,NN1,NN2)=ZZ1
                    ZZ2=TI1(N1,N2)
                    IT11(M1,NN1,NN2)=ZZ2
                    ZZ3=TR1(N1,N22)
                    RT12(M1,NN1,NN2)=ZZ3
                    ZZ4=TI1(N1,N22)
                    IT12(M1,NN1,NN2)=ZZ4
                    ZZ5=TR1(N11,N2)
                    RT21(M1,NN1,NN2)=ZZ5
                    ZZ6=TI1(N11,N2)
                    IT21(M1,NN1,NN2)=ZZ6
                    ZZ7=TR1(N11,N22)
                    RT22(M1,NN1,NN2)=ZZ7
                    ZZ8=TI1(N11,N22)
                    IT22(M1,NN1,NN2)=ZZ8
                    QSC=QSC+(ZZ1*ZZ1+ZZ2*ZZ2+ZZ3*ZZ3+ZZ4*ZZ4&
                    +ZZ5*ZZ5+ZZ6*ZZ6+ZZ7*ZZ7+ZZ8*ZZ8)*2D0
214             CONTINUE
                NNM=2*NM
                QXT=0D0
                DO 215 N=1,NNM
                    QXT=QXT+TR1(N,N)*2D0
215             CONTINUE
                QSCA=QSCA+QSC
                QEXT=QEXT+QXT
                !        PRINT 7800,M,DABS(QXT),QSC,NMAX
7800            FORMAT(' m=',I3,'  qxt=',D12.6,'  qsc=',D12.6,&
                '  nmax=',I3)
220         CONTINUE
            WALB=-QSCA/QEXT
            IF (WALB.GT.1D0+DDELT) PRINT 9111
9111        FORMAT ('WARNING: W IS GREATER THAN 1')

            !  COMPUTATION OF THE AMPLITUDE AND PHASE MATRICES

            !  AMPLITUDE MATRIX [Eqs. (2)-(4) of Ref. 6]
            CALL AMPL (NMAX,LAM,THET0,THET,PHI0,PHI,ALPHA,BETA,&
            S11,S12,S21,S22)
            S11 = S11/1E6
            S12 = S12/1E6
            S21 = S21/1E6
            S22 = S22/1E6
            !      WRITE(*,5002)THET0,THET,PHI0,PHI
            !      WRITE(*,5001)S11,S12
            !      WRITE(*,5001)S21,S22


5000        FORMAT ('PHASE MATRIX')
5001        FORMAT (4D15.4)
5002        FORMAT (4D10.3)

            RETURN
        END
 
        !********************************************************************
                                           
        !   CALCULATION OF THE AMPLITUDE MATRIX
 
        SUBROUTINE AMPL (NMAX,DLAM,TL,TL1,PL,PL1,ALPHA,BETA,&
        VV,VH,HV,HH)
            !      INCLUDE 'ampld.par.f'
            Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1, &
            NPL=NPN2+1, NPN3=NPN1+1, &
            NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

            IMPLICIT REAL*8 (A-B,D-H,O-Z), COMPLEX*16 (C)
            REAL*8 AL(3,2),AL1(3,2),AP(2,3),AP1(2,3),B(3,3),&
            R(2,2),R1(2,2),C(3,2),CA,CB,CT,CP,CTP,CPP,CT1,CP1,&
            CTP1,CPP1
            REAL*8 DV1(NPN6),DV2(NPN6),DV01(NPN6),DV02(NPN6)
            REAL*4&
            TR11(NPN6,NPN4,NPN4),TR12(NPN6,NPN4,NPN4),&
            TR21(NPN6,NPN4,NPN4),TR22(NPN6,NPN4,NPN4),&
            TI11(NPN6,NPN4,NPN4),TI12(NPN6,NPN4,NPN4),&
            TI21(NPN6,NPN4,NPN4),TI22(NPN6,NPN4,NPN4)
            COMPLEX*16 CAL(NPN4,NPN4),VV,VH,HV,HH
            COMMON /TMAT/ TR11,TR12,TR21,TR22,TI11,TI12,TI21,TI22

            IF (ALPHA.LT.0D0.OR.ALPHA.GT.360D0.OR.&
            BETA.LT.0D0.OR.BETA.GT.180D0.OR.&
            TL.LT.0D0.OR.TL.GT.180D0.OR.&
            TL1.LT.0D0.OR.TL1.GT.180D0.OR.&
            PL.LT.0D0.OR.PL.GT.360D0.OR.&
            PL1.LT.0D0.OR.PL1.GT.360D0) THEN
         
                !         WRITE(*,*)ALPHA, BETA, TL, TL1, PL, PL1

                WRITE (6,2000)
                STOP
            ELSE
            CONTINUE
        ENDIF
2000    FORMAT ('AN ANGULAR PARAMETER IS OUTSIDE ITS',&
        ' ALLOWABLE RANGE')
        PIN=DACOS(-1D0)
        PIN2=PIN*0.5D0
        PI=PIN/180D0
        ALPH=ALPHA*PI
        BET=BETA*PI
        THETL=TL*PI
        PHIL=PL*PI
        THETL1=TL1*PI
        PHIL1=PL1*PI

        EPS=1D-7
        IF (THETL.LT.PIN2) THETL=THETL+EPS
        IF (THETL.GT.PIN2) THETL=THETL-EPS
        IF (THETL1.LT.PIN2) THETL1=THETL1+EPS
        IF (THETL1.GT.PIN2) THETL1=THETL1-EPS
        IF (PHIL.LT.PIN) PHIL=PHIL+EPS
        IF (PHIL.GT.PIN) PHIL=PHIL-EPS
        IF (PHIL1.LT.PIN) PHIL1=PHIL1+EPS
        IF (PHIL1.GT.PIN) PHIL1=PHIL1-EPS
        IF (BET.LE.PIN2.AND.PIN2-BET.LE.EPS) BET=BET-EPS
        IF (BET.GT.PIN2.AND.BET-PIN2.LE.EPS) BET=BET+EPS
      
        !_____________COMPUTE THETP, PHIP, THETP1, AND PHIP1, EQS. (8), (19), AND (20)

        CB=DCOS(BET)
        SB=DSIN(BET)
        CT=DCOS(THETL)
        ST=DSIN(THETL)
        CP=DCOS(PHIL-ALPH)
        SP=DSIN(PHIL-ALPH)
        CTP=CT*CB+ST*SB*CP
        THETP=DACOS(CTP)
        CPP=CB*ST*CP-SB*CT
        SPP=ST*SP
        PHIP=DATAN(SPP/CPP)
        IF (PHIP.GT.0D0.AND.SP.LT.0D0) PHIP=PHIP+PIN
        IF (PHIP.LT.0D0.AND.SP.GT.0D0) PHIP=PHIP+PIN
        IF (PHIP.LT.0D0) PHIP=PHIP+2D0*PIN

        CT1=DCOS(THETL1)
        ST1=DSIN(THETL1)
        CP1=DCOS(PHIL1-ALPH)
        SP1=DSIN(PHIL1-ALPH)
        CTP1=CT1*CB+ST1*SB*CP1
        THETP1=DACOS(CTP1)
        CPP1=CB*ST1*CP1-SB*CT1
        SPP1=ST1*SP1
        PHIP1=DATAN(SPP1/CPP1)
        IF (PHIP1.GT.0D0.AND.SP1.LT.0D0) PHIP1=PHIP1+PIN
        IF (PHIP1.LT.0D0.AND.SP1.GT.0D0) PHIP1=PHIP1+PIN
        IF (PHIP1.LT.0D0) PHIP1=PHIP1+2D0*PIN

        !____________COMPUTE MATRIX BETA, EQ. (21)

        CA=DCOS(ALPH)
        SA=DSIN(ALPH)
        B(1,1)=CA*CB
        B(1,2)=SA*CB
        B(1,3)=-SB
        B(2,1)=-SA
        B(2,2)=CA
        B(2,3)=0D0
        B(3,1)=CA*SB
        B(3,2)=SA*SB
        B(3,3)=CB

        !____________COMPUTE MATRICES AL AND AL1, EQ. (14)

        CP=DCOS(PHIL)
        SP=DSIN(PHIL)
        CP1=DCOS(PHIL1)
        SP1=DSIN(PHIL1)
        AL(1,1)=CT*CP
        AL(1,2)=-SP
        AL(2,1)=CT*SP
        AL(2,2)=CP
        AL(3,1)=-ST
        AL(3,2)=0D0
        AL1(1,1)=CT1*CP1
        AL1(1,2)=-SP1
        AL1(2,1)=CT1*SP1
        AL1(2,2)=CP1
        AL1(3,1)=-ST1
        AL1(3,2)=0D0

        !____________COMPUTE MATRICES AP^(-1) AND AP1^(-1), EQ. (15)

        CT=CTP
        ST=DSIN(THETP)
        CP=DCOS(PHIP)
        SP=DSIN(PHIP)
        CT1=CTP1
        ST1=DSIN(THETP1)
        CP1=DCOS(PHIP1)
        SP1=DSIN(PHIP1)
        AP(1,1)=CT*CP
        AP(1,2)=CT*SP
        AP(1,3)=-ST
        AP(2,1)=-SP
        AP(2,2)=CP
        AP(2,3)=0D0
        AP1(1,1)=CT1*CP1
        AP1(1,2)=CT1*SP1
        AP1(1,3)=-ST1
        AP1(2,1)=-SP1
        AP1(2,2)=CP1
        AP1(2,3)=0D0

        !____________COMPUTE MATRICES R AND R^(-1), EQ. (13)
        DO I=1,3
            DO J=1,2
                X=0D0
                DO K=1,3
                    X=X+B(I,K)*AL(K,J)
                ENDDO
                C(I,J)=X
            ENDDO
        ENDDO
        DO I=1,2
            DO J=1,2
                X=0D0
                DO K=1,3
                    X=X+AP(I,K)*C(K,J)
                ENDDO
                R(I,J)=X
            ENDDO
        ENDDO
        DO I=1,3
            DO J=1,2
                X=0D0
                DO K=1,3
                    X=X+B(I,K)*AL1(K,J)
                ENDDO
                C(I,J)=X
            ENDDO
        ENDDO
        DO I=1,2
            DO J=1,2
                X=0D0
                DO K=1,3
                    X=X+AP1(I,K)*C(K,J)
                ENDDO
                R1(I,J)=X
            ENDDO
        ENDDO
        D=1D0/(R1(1,1)*R1(2,2)-R1(1,2)*R1(2,1))
        X=R1(1,1)
        R1(1,1)=R1(2,2)*D
        R1(1,2)=-R1(1,2)*D
        R1(2,1)=-R1(2,1)*D
        R1(2,2)=X*D

        CI=(0D0,1D0)
        DO 5 NN=1,NMAX
            DO 5 N=1,NMAX
                CN=CI**(NN-N-1)
                DNN=DFLOAT((2*N+1)*(2*NN+1))
                DNN=DNN/DFLOAT( N*NN*(N+1)*(NN+1) )
                RN=DSQRT(DNN)
                CAL(N,NN)=CN*RN
5           CONTINUE
            DCTH0=CTP
            DCTH=CTP1
            PH=PHIP1-PHIP
            VV=(0D0,0D0)
            VH=(0D0,0D0)
            HV=(0D0,0D0)
            HH=(0D0,0D0)
            DO 500 M=0,NMAX
                M1=M+1
                NMIN=MAX(M,1)
                CALL VIGAMPL (DCTH, NMAX, M, DV1, DV2)
                CALL VIGAMPL (DCTH0, NMAX, M, DV01, DV02)
                FC=2D0*DCOS(M*PH)
                FS=2D0*DSIN(M*PH)
                DO 400 NN=NMIN,NMAX
                    DV1NN=M*DV01(NN)
                    DV2NN=DV02(NN)
                    DO 400 N=NMIN,NMAX
                        DV1N=M*DV1(N)
                        DV2N=DV2(N)

                        CT11=DCMPLX(TR11(M1,N,NN),TI11(M1,N,NN))
                        CT22=DCMPLX(TR22(M1,N,NN),TI22(M1,N,NN))

                        IF (M.EQ.0) THEN

                            CN=CAL(N,NN)*DV2N*DV2NN

                            VV=VV+CN*CT22
                            HH=HH+CN*CT11

                        ELSE

                            CT12=DCMPLX(TR12(M1,N,NN),TI12(M1,N,NN))
                            CT21=DCMPLX(TR21(M1,N,NN),TI21(M1,N,NN))

                            CN1=CAL(N,NN)*FC
                            CN2=CAL(N,NN)*FS

                            D11=DV1N*DV1NN
                            D12=DV1N*DV2NN
                            D21=DV2N*DV1NN
                            D22=DV2N*DV2NN

                            VV=VV+(CT11*D11+CT21*D21 &
                            +CT12*D12+CT22*D22)*CN1

                            VH=VH+(CT11*D12+CT21*D22   &
                            +CT12*D11+CT22*D21)*CN2

                            HV=HV-(CT11*D21+CT21*D11&
                            +CT12*D22+CT22*D12)*CN2

                            HH=HH+(CT11*D22+CT21*D12&
                            +CT12*D21+CT22*D11)*CN1
                        ENDIF
400                 CONTINUE
500             CONTINUE
                DK=2D0*PIN/DLAM
                VV=VV/DK
                VH=VH/DK
                HV=HV/DK
                HH=HH/DK
                CVV=VV*R(1,1)+VH*R(2,1)
                CVH=VV*R(1,2)+VH*R(2,2)
                CHV=HV*R(1,1)+HH*R(2,1)
                CHH=HV*R(1,2)+HH*R(2,2)
                VV=R1(1,1)*CVV+R1(1,2)*CHV
                VH=R1(1,1)*CVH+R1(1,2)*CHH
                HV=R1(2,1)*CVV+R1(2,2)*CHV
                HH=R1(2,1)*CVH+R1(2,2)*CHH
      
                !      WRITE (6,1005) TL,TL1,PL,PL1,ALPHA,BETA
                !      WRITE (6,10071) TL,TL1,PL,PL1
                !	WRITE (7,10071) TL,TL1,PL,PL1
                !      WRITE (6,1006)
                !      PRINT 1101, VV
                !      PRINT 1102, VH
                !      PRINT 1103, HV
                !      PRINT 1104, HH
                !      WRITE(6,1007) VV,VH
                !	WRITE(6,1007) HV,HH
1101            FORMAT ('S11=',D11.5,' + i*',D11.5)
1102            FORMAT ('S12=',D11.5,' + i*',D11.5)
1103            FORMAT ('S21=',D11.5,' + i*',D11.5)
1104            FORMAT ('S22=',D11.5,' + i*',D11.5)
1005            FORMAT ('thet0=',F6.2,'  thet=',F6.2,'phi0=',F6.2,&
                '  phi=',F6.2)
1007            FORMAT (4D15.5)
10071           FORMAT (4F10.2)
1006            FORMAT ('AMPLITUDE MATRIX')
                RETURN
            END
      
            !*****************************************************************
            !
            !     Calculation of the functions
            !     DV1(N)=dvig(0,m,n,arccos x)/sin(arccos x)
            !     and
            !     DV2(N)=[d/d(arccos x)] dvig(0,m,n,arccos x)
            !     1.LE.N.LE.NMAX
            !     0.LE.X.LE.1

            SUBROUTINE VIGAMPL (X, NMAX, M, DV1, DV2)
                !      INCLUDE 'ampld.par.f'
                Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1,&
                NPL=NPN2+1, NPN3=NPN1+1,&
                NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                IMPLICIT REAL*8 (A-H,O-Z)
                REAL*8 DV1(NPN6), DV2(NPN6)
                DO 1 N=1,NMAX
                    DV1(N)=0D0
                    DV2(N)=0D0
1               CONTINUE
                DX=DABS(X)
                IF (DABS(1D0-DX).LE.1D-10) GO TO 100
                A=1D0
                QS=DSQRT(1D0-X*X)
                QS1=1D0/QS
                DSI=QS1
                IF (M.NE.0) GO TO 20
                D1=1D0
                D2=X
                DO 5 N=1,NMAX
                    QN=DFLOAT(N)
                    QN1=DFLOAT(N+1)
                    QN2=DFLOAT(2*N+1)
                    D3=(QN2*X*D2-QN*D1)/QN1
                    DER=QS1*(QN1*QN/QN2)*(-D1+D3)
                    DV1(N)=D2*DSI
                    DV2(N)=DER
                    D1=D2
                    D2=D3
5               CONTINUE
                RETURN
20              QMM=DFLOAT(M*M)
                DO 25 I=1,M
                    I2=I*2
                    A=A*DSQRT(DFLOAT(I2-1)/DFLOAT(I2))*QS
25              CONTINUE
                D1=0D0
                D2=A
                DO 30 N=M,NMAX
                    QN=DFLOAT(N)
                    QN2=DFLOAT(2*N+1)
                    QN1=DFLOAT(N+1)
                    QNM=DSQRT(QN*QN-QMM)
                    QNM1=DSQRT(QN1*QN1-QMM)
                    D3=(QN2*X*D2-QNM*D1)/QNM1
                    DER=QS1*(-QN1*QNM*D1+QN*QNM1*D3)/QN2
                    DV1(N)=D2*DSI
                    DV2(N)=DER
                    D1=D2
                    D2=D3
30              CONTINUE
                RETURN
100             IF (M.NE.1) RETURN
                DO 110 N=1,NMAX
                    DN=DFLOAT(N*(N+1))
                    DN=0.5D0*DSQRT(DN)
                    IF (X.LT.0D0) DN=DN*(-1)**(N+1)
                    DV1(N)=DN
                    IF (X.LT.0D0) DN=-DN
                    DV2(N)=DN
110             CONTINUE
                RETURN
            END

            !**********************************************************************

            SUBROUTINE CONST (NGAUSS,NMAX,MMAX,P,X,W,AN,ANN,S,SS,NP,EPS)
                IMPLICIT REAL*8 (A-H,O-Z)
                !      INCLUDE 'ampld.par.f'
                Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1,&
                NPL=NPN2+1, NPN3=NPN1+1,&
                NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                REAL*8 X(NPNG2),W(NPNG2),X1(NPNG1),W1(NPNG1),&
                X2(NPNG1),W2(NPNG1),&
                S(NPNG2),SS(NPNG2),&
                AN(NPN1),ANN(NPN1,NPN1),DD(NPN1)
 
                DO 10 N=1,NMAX
                    NN=N*(N+1)
                    AN(N)=DFLOAT(NN)
                    D=DSQRT(DFLOAT(2*N+1)/DFLOAT(NN))
                    DD(N)=D
                    DO 10 N1=1,N
                        DDD=D*DD(N1)*0.5D0
                        ANN(N,N1)=DDD
                        ANN(N1,N)=DDD
10                  CONTINUE
                    NG=2*NGAUSS
                    IF (NP.EQ.-2) GO  TO 11
                    CALL GAUSS(NG,0,0,X,W)
                    GO TO 19
11                  NG1=DFLOAT(NGAUSS)/2D0
                    NG2=NGAUSS-NG1
                    XX=-DCOS(DATAN(EPS))
                    CALL GAUSS(NG1,0,0,X1,W1)
                    CALL GAUSS(NG2,0,0,X2,W2)
                    DO 12 I=1,NG1
                        W(I)=0.5D0*(XX+1D0)*W1(I)
                        X(I)=0.5D0*(XX+1D0)*X1(I)+0.5D0*(XX-1D0)
12                  CONTINUE
                    DO 14 I=1,NG2
                        W(I+NG1)=-0.5D0*XX*W2(I)
                        X(I+NG1)=-0.5D0*XX*X2(I)+0.5D0*XX
14                  CONTINUE
                    DO 16 I=1,NGAUSS
                        W(NG-I+1)=W(I)
                        X(NG-I+1)=-X(I)
16                  CONTINUE
                    19 DO 20 I=1,NGAUSS
                        Y=X(I)
                        Y=1D0/(1D0-Y*Y)
                        SS(I)=Y
                        SS(NG-I+1)=Y
                        Y=DSQRT(Y)
                        S(I)=Y
                        S(NG-I+1)=Y
20                  CONTINUE
                    RETURN
                END
 
                !**********************************************************************
 
                SUBROUTINE VARY (LAM,MRR,MRI,A,EPS,NP,NGAUSS,X,P,PPI,PIR,PII,&
                R,DR,DDR,DRR,DRI,NMAX)
                    !      INCLUDE 'ampld.par.f'
                    Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1, &
                    NPL=NPN2+1, NPN3=NPN1+1, &
                    NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                    IMPLICIT REAL*8 (A-H,O-Z)
                    REAL*8  X(NPNG2),R(NPNG2),DR(NPNG2),MRR,MRI,LAM,&
                    Z(NPNG2),ZR(NPNG2),ZI(NPNG2),&
                    J(NPNG2,NPN1),Y(NPNG2,NPN1),JR(NPNG2,NPN1),&
                    JI(NPNG2,NPN1),DJ(NPNG2,NPN1),&
                    DJR(NPNG2,NPN1),DJI(NPNG2,NPN1),DDR(NPNG2),&
                    DRR(NPNG2),DRI(NPNG2),&
                    DY(NPNG2,NPN1)
                    COMMON /CBESS/ J,Y,JR,JI,DJ,DY,DJR,DJI
                    NG=NGAUSS*2
                    IF (NP.GT.0) CALL RSP2(X,NG,A,EPS,NP,R,DR)
                    IF (NP.EQ.-1) CALL RSP1(X,NG,NGAUSS,A,EPS,NP,R,DR)
                    IF (NP.EQ.-2) CALL RSP3(X,NG,NGAUSS,A,EPS,R,DR)
                    IF (NP.EQ.-3) CALL RSP4(X,NG,A,R,DR)
                    PI=P*2D0/LAM
                    PPI=PI*PI
                    PIR=PPI*MRR
                    PII=PPI*MRI
                    V=1D0/(MRR*MRR+MRI*MRI)
                    PRR=MRR*V
                    PRI=-MRI*V
                    TA=0D0
                    DO 10 I=1,NG
                        VV=DSQRT(R(I))
                        V=VV*PI
                        TA=MAX(TA,V)
                        VV=1D0/V
                        DDR(I)=VV
                        DRR(I)=PRR*VV
                        DRI(I)=PRI*VV
                        V1=V*MRR
                        V2=V*MRI
                        Z(I)=V
                        ZR(I)=V1
                        ZI(I)=V2
10                  CONTINUE
                    IF (NMAX.GT.NPN1) PRINT 9000,NMAX,NPN1
                    IF (NMAX.GT.NPN1) STOP
9000                FORMAT(' NMAX = ',I2,', i.e., greater than ',I3)
                    TB=TA*DSQRT(MRR*MRR+MRI*MRI)
                    TB=DMAX1(TB,DFLOAT(NMAX))
                    NNMAX1=1.2D0*DSQRT(DMAX1(TA,DFLOAT(NMAX)))+3D0
                    NNMAX2=(TB+4D0*(TB**0.33333D0)+1.2D0*DSQRT(TB))
                    NNMAX2=NNMAX2-NMAX+5
                    CALL BESS(Z,ZR,ZI,NG,NMAX,NNMAX1,NNMAX2)
                    RETURN
                END
 
                !**********************************************************************
 
                SUBROUTINE RSP1 (X,NG,NGAUSS,REV,EPS,NP,R,DR)
                    IMPLICIT REAL*8 (A-H,O-Z)
                    REAL*8 X(NG),R(NG),DR(NG)
                    A=REV*EPS**(1D0/3D0)
                    AA=A*A
                    EE=EPS*EPS
                    EE1=EE-1D0
                    DO 50 I=1,NGAUSS
                        C=X(I)
                        CC=C*C
                        SS=1D0-CC
                        S=DSQRT(SS)
                        RR=1D0/(SS+EE*CC)
                        R(I)=AA*RR
                        R(NG-I+1)=R(I)
                        DR(I)=RR*C*S*EE1
                        DR(NG-I+1)=-DR(I)
50                  CONTINUE
                    RETURN
                END
 
                !**********************************************************************
 
                SUBROUTINE RSP2 (X,NG,REV,EPS,N,R,DR)
                    IMPLICIT REAL*8 (A-H,O-Z)
                    REAL*8 X(NG),R(NG),DR(NG)
                    DNP=DFLOAT(N)
                    DN=DNP*DNP
                    DN4=DN*4D0
                    EP=EPS*EPS
                    A=1D0+1.5D0*EP*(DN4-2D0)/(DN4-1D0)
                    I=(DNP+0.1D0)*0.5D0
                    I=2*I
                    IF (I.EQ.N) A=A-3D0*EPS*(1D0+0.25D0*EP)/&
                    (DN-1D0)-0.25D0*EP*EPS/(9D0*DN-1D0)
                    R0=REV*A**(-1D0/3D0)
                    DO 50 I=1,NG
                        XI=DACOS(X(I))*DNP
                        RI=R0*(1D0+EPS*DCOS(XI))
                        R(I)=RI*RI
                        DR(I)=-R0*EPS*DNP*DSIN(XI)/RI
                    !        WRITE (6,*) I,R(I),DR(I)
50                  CONTINUE
                    RETURN
                END
 
                !**********************************************************************
 
                SUBROUTINE RSP3 (X,NG,NGAUSS,REV,EPS,R,DR)
                    IMPLICIT REAL*8 (A-H,O-Z)
                    REAL*8 X(NG),R(NG),DR(NG)
                    H=REV*( (2D0/(3D0*EPS*EPS))**(1D0/3D0) )
                    A=H*EPS
                    DO 50 I=1,NGAUSS
                        CO=-X(I)
                        SI=DSQRT(1D0-CO*CO)
                        IF (SI/CO.GT.A/H) GO TO 20
                        RAD=H/CO
                        RTHET=H*SI/(CO*CO)
                        GO TO 30
20                      RAD=A/SI
                        RTHET=-A*CO/(SI*SI)
30                      R(I)=RAD*RAD
                        R(NG-I+1)=R(I)
                        DR(I)=-RTHET/RAD
                        DR(NG-I+1)=-DR(I)
50                  CONTINUE
                    RETURN
                END
 
                !**********************************************************************
                !                                                                     *
                !   Calculation of the functions R(I)=r(y)**2 and                     *
                !   DR(I)=((d/dy)r(y))/r(y) for a distorted                           *
                !   droplet specified by the parameters r_ev (equal-volume-sphere     *
                !   radius) and c_n (Chebyshev expansion coefficients)                *
                !   Y(I)=arccos(X(I))                                                 *
                !   1.LE.I.LE.NG                                                      *
                !   X - arguments                                                     *
                !                                                                     *
                !**********************************************************************

                SUBROUTINE RSP4 (X,NG,REV,R,DR)
                    PARAMETER (NC=10)
                    IMPLICIT REAL*8 (A-H,O-Z)
                    REAL*8 X(NG),R(NG),DR(NG),C(0:NC)
                    COMMON /CDROP/ C,R0V
                    R0=REV*R0V
                    DO I=1,NG
                        XI=DACOS(X(I))
                        RI=1D0+C(0)
                        DRI=0D0
                        DO N=1,NC
                            XIN=XI*N
                            RI=RI+C(N)*DCOS(XIN)
                            DRI=DRI-C(N)*N*DSIN(XIN)
                        ENDDO
                        RI=RI*R0
                        DRI=DRI*R0
                        R(I)=RI*RI
                        DR(I)=DRI/RI
                    !        WRITE (6,*) I,R(I),DR(I)
                    ENDDO
                    RETURN
                END

                !*********************************************************************
 
                SUBROUTINE BESS (X,XR,XI,NG,NMAX,NNMAX1,NNMAX2)
                    !      INCLUDE 'ampld.par.f'
                    Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1, &
                    NPL=NPN2+1, NPN3=NPN1+1,&
                    NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                    IMPLICIT REAL*8 (A-H,O-Z)
                    REAL*8 X(NG),XR(NG),XI(NG),&
                    J(NPNG2,NPN1),Y(NPNG2,NPN1),JR(NPNG2,NPN1),&
                    JI(NPNG2,NPN1),DJ(NPNG2,NPN1),DY(NPNG2,NPN1),&
                    DJR(NPNG2,NPN1),DJI(NPNG2,NPN1),&
                    AJ(NPN1),AY(NPN1),AJR(NPN1),AJI(NPN1),&
                    ADJ(NPN1),ADY(NPN1),ADJR(NPN1),&
                    ADJI(NPN1)
                    COMMON /CBESS/ J,Y,JR,JI,DJ,DY,DJR,DJI
 
                    DO 10 I=1,NG
                        XX=X(I)
                        CALL RJB(XX,AJ,ADJ,NMAX,NNMAX1)
                        CALL RYB(XX,AY,ADY,NMAX)
                        YR=XR(I)
                        YI=XI(I)
                        CALL CJB(YR,YI,AJR,AJI,ADJR,ADJI,NMAX,NNMAX2)
                        DO 10 N=1,NMAX
                            J(I,N)=AJ(N)
                            Y(I,N)=AY(N)
                            JR(I,N)=AJR(N)
                            JI(I,N)=AJI(N)
                            DJ(I,N)=ADJ(N)
                            DY(I,N)=ADY(N)
                            DJR(I,N)=ADJR(N)
                            DJI(I,N)=ADJI(N)
10                      CONTINUE
                        RETURN
                    END
 
                    !**********************************************************************
 
                    SUBROUTINE RJB(X,Y,U,NMAX,NNMAX)
                        IMPLICIT REAL*8 (A-H,O-Z)
                        REAL*8 Y(NMAX),U(NMAX),Z(800)
                        L=NMAX+NNMAX
                        XX=1D0/X
                        Z(L)=1D0/(DFLOAT(2*L+1)*XX)
                        L1=L-1
                        DO 5 I=1,L1
                            I1=L-I
                            Z(I1)=1D0/(DFLOAT(2*I1+1)*XX-Z(I1+1))
5                       CONTINUE
                        Z0=1D0/(XX-Z(1))
                        Y0=Z0*DCOS(X)*XX
                        Y1=Y0*Z(1)
                        U(1)=Y0-Y1*XX
                        Y(1)=Y1
                        DO 10 I=2,NMAX
                            YI1=Y(I-1)
                            YI=YI1*Z(I)
                            U(I)=YI1-DFLOAT(I)*YI*XX
                            Y(I)=YI
10                      CONTINUE
                        RETURN
                    END
 
                    !**********************************************************************
 
                    SUBROUTINE RYB(X,Y,V,NMAX)
                        IMPLICIT REAL*8 (A-H,O-Z)
                        REAL*8 Y(NMAX),V(NMAX)
                        C=DCOS(X)
                        S=DSIN(X)
                        X1=1D0/X
                        X2=X1*X1
                        X3=X2*X1
                        Y1=-C*X2-S*X1
                        Y(1)=Y1
                        Y(2)=(-3D0*X3+X1)*C-3D0*X2*S
                        NMAX1=NMAX-1
                        DO 5 I=2,NMAX1
5                           Y(I+1)=DFLOAT(2*I+1)*X1*Y(I)-Y(I-1)
                            V(1)=-X1*(C+Y1)
                            DO 10 I=2,NMAX
10                              V(I)=Y(I-1)-DFLOAT(I)*X1*Y(I)
                                RETURN
                            END
 
                            !**********************************************************************
                            !                                                                     *
                            !   CALCULATION OF SPHERICAL BESSEL FUNCTIONS OF THE FIRST KIND       *
                            !   J=JR+I*JI OF COMPLEX ARGUMENT X=XR+I*XI OF ORDERS FROM 1 TO NMAX  *
                            !   BY USING BACKWARD RECURSION. PARAMETR NNMAX DETERMINES NUMERICAL  *
                            !   ACCURACY. U=UR+I*UI - FUNCTION (1/X)(D/DX)(X*J(X))                *
                            !                                                                     *
                            !**********************************************************************
 
                            SUBROUTINE CJB (XR,XI,YR,YI,UR,UI,NMAX,NNMAX)
                                !      INCLUDE 'ampld.par.f'
                                Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1,&
                                NPL=NPN2+1, NPN3=NPN1+1,&
                                NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                                IMPLICIT REAL*8 (A-H,O-Z)
                                REAL*8 YR(NMAX),YI(NMAX),UR(NMAX),UI(NMAX)
                                REAL*8 CYR(NPN1),CYI(NPN1),CZR(1200),CZI(1200),&
                                CUR(NPN1),CUI(NPN1)
                                L=NMAX+NNMAX
                                XRXI=1D0/(XR*XR+XI*XI)
                                CXXR=XR*XRXI
                                CXXI=-XI*XRXI
                                QF=1D0/DFLOAT(2*L+1)
                                CZR(L)=XR*QF
                                CZI(L)=XI*QF
                                L1=L-1
                                DO I=1,L1
                                    I1=L-I
                                    QF=DFLOAT(2*I1+1)
                                    AR=QF*CXXR-CZR(I1+1)
                                    AI=QF*CXXI-CZI(I1+1)
                                    ARI=1D0/(AR*AR+AI*AI)
                                    CZR(I1)=AR*ARI
                                    CZI(I1)=-AI*ARI
                                ENDDO
                                AR=CXXR-CZR(1)
                                AI=CXXI-CZI(1)
                                ARI=1D0/(AR*AR+AI*AI)
                                CZ0R=AR*ARI
                                CZ0I=-AI*ARI
                                CR=DCOS(XR)*DCOSH(XI)
                                CI=-DSIN(XR)*DSINH(XI)
                                AR=CZ0R*CR-CZ0I*CI
                                AI=CZ0I*CR+CZ0R*CI
                                CY0R=AR*CXXR-AI*CXXI
                                CY0I=AI*CXXR+AR*CXXI
                                CY1R=CY0R*CZR(1)-CY0I*CZI(1)
                                CY1I=CY0I*CZR(1)+CY0R*CZI(1)
                                AR=CY1R*CXXR-CY1I*CXXI
                                AI=CY1I*CXXR+CY1R*CXXI
                                CU1R=CY0R-AR
                                CU1I=CY0I-AI
                                CYR(1)=CY1R
                                CYI(1)=CY1I
                                CUR(1)=CU1R
                                CUI(1)=CU1I
                                YR(1)=CY1R
                                YI(1)=CY1I
                                UR(1)=CU1R
                                UI(1)=CU1I
                                DO I=2,NMAX
                                    QI=DFLOAT(I)
                                    CYI1R=CYR(I-1)
                                    CYI1I=CYI(I-1)
                                    CYIR=CYI1R*CZR(I)-CYI1I*CZI(I)
                                    CYII=CYI1I*CZR(I)+CYI1R*CZI(I)
                                    AR=CYIR*CXXR-CYII*CXXI
                                    AI=CYII*CXXR+CYIR*CXXI
                                    CUIR=CYI1R-QI*AR
                                    CUII=CYI1I-QI*AI
                                    CYR(I)=CYIR
                                    CYI(I)=CYII
                                    CUR(I)=CUIR
                                    CUI(I)=CUII
                                    YR(I)=CYIR
                                    YI(I)=CYII
                                    UR(I)=CUIR
                                    UI(I)=CUII
                                ENDDO
                                RETURN
                            END
 
                            !**********************************************************************
 
                            SUBROUTINE TMATR0 (NGAUSS,X,W,AN,ANN,S,SS,PPI,PIR,PII,R,DR,DDR,&
                            DRR,DRI,NMAX,NCHECK)
                                !      INCLUDE 'ampld.par.f'
                                Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1, &
                                NPL=NPN2+1, NPN3=NPN1+1,  &
                                NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                                IMPLICIT REAL*8 (A-H,O-Z)
                                REAL*8  X(NPNG2),W(NPNG2),AN(NPN1),S(NPNG2),SS(NPNG2),&
                                R(NPNG2),DR(NPNG2),SIG(NPN2),&
                                J(NPNG2,NPN1),Y(NPNG2,NPN1),&
                                JR(NPNG2,NPN1),JI(NPNG2,NPN1),DJ(NPNG2,NPN1),&
                                DY(NPNG2,NPN1),DJR(NPNG2,NPN1),&
                                DJI(NPNG2,NPN1),DDR(NPNG2),DRR(NPNG2),&
                                D1(NPNG2,NPN1),D2(NPNG2,NPN1),&
                                DRI(NPNG2),DS(NPNG2),DSS(NPNG2),RR(NPNG2),&
                                DV1(NPN1),DV2(NPN1)
 
                                REAL*8  R11(NPN1,NPN1),R12(NPN1,NPN1),&
                                R21(NPN1,NPN1),R22(NPN1,NPN1),&
                                I11(NPN1,NPN1),I12(NPN1,NPN1),&
                                I21(NPN1,NPN1),I22(NPN1,NPN1),&
                                RG11(NPN1,NPN1),RG12(NPN1,NPN1),&
                                RG21(NPN1,NPN1),RG22(NPN1,NPN1),&
                                IG11(NPN1,NPN1),IG12(NPN1,NPN1),&
                                IG21(NPN1,NPN1),IG22(NPN1,NPN1),&
                                ANN(NPN1,NPN1),&
                                QR(NPN2,NPN2),QI(NPN2,NPN2),&
                                RGQR(NPN2,NPN2),RGQI(NPN2,NPN2),&
                                TQR(NPN2,NPN2),TQI(NPN2,NPN2),&
                                TRGQR(NPN2,NPN2),TRGQI(NPN2,NPN2)
                                REAL*8 TR1(NPN2,NPN2),TI1(NPN2,NPN2)
                                COMMON /TMAT99/ &
                                R11,R12,R21,R22,I11,I12,I21,I22,RG11,RG12,RG21,RG22,&
                                IG11,IG12,IG21,IG22
                                COMMON /CBESS/ J,Y,JR,JI,DJ,DY,DJR,DJI
                                COMMON /CT/ TR1,TI1
                                COMMON /CTT/ QR,QI,RGQR,RGQI
                                MM1=1
                                NNMAX=NMAX+NMAX
                                NG=2*NGAUSS
                                NGSS=NG
                                FACTOR=1D0
                                IF (NCHECK.EQ.1) THEN
                                    NGSS=NGAUSS
                                    FACTOR=2D0
                                ELSE
                                CONTINUE
                            ENDIF
                            SI=1D0
                            DO 5 N=1,NNMAX
                                SI=-SI
                                SIG(N)=SI
5                           CONTINUE
                            20 DO 25 I=1,NGAUSS
                                I1=NGAUSS+I
                                I2=NGAUSS-I+1
                                CALL VIG ( X(I1), NMAX, 0, DV1, DV2)
                                DO 25 N=1,NMAX
                                    SI=SIG(N)
                                    DD1=DV1(N)
                                    DD2=DV2(N)
                                    D1(I1,N)=DD1
                                    D2(I1,N)=DD2
                                    D1(I2,N)=DD1*SI
                                    D2(I2,N)=-DD2*SI
25                              CONTINUE
                                30 DO 40 I=1,NGSS
                                    RR(I)=W(I)*R(I)
40                              CONTINUE
 
                                DO 300  N1=MM1,NMAX
                                    AN1=AN(N1)
                                    DO 300 N2=MM1,NMAX
                                        AN2=AN(N2)
                                        AR12=0D0
                                        AR21=0D0
                                        AI12=0D0
                                        AI21=0D0
                                        GR12=0D0
                                        GR21=0D0
                                        GI12=0D0
                                        GI21=0D0
                                        IF (NCHECK.EQ.1.AND.SIG(N1+N2).LT.0D0) GO TO 205

                                        DO 200 I=1,NGSS
                                            D1N1=D1(I,N1)
                                            D2N1=D2(I,N1)
                                            D1N2=D1(I,N2)
                                            D2N2=D2(I,N2)
                                            A12=D1N1*D2N2
                                            A21=D2N1*D1N2
                                            A22=D2N1*D2N2
                                            AA1=A12+A21
 
                                            QJ1=J(I,N1)
                                            QY1=Y(I,N1)
                                            QJR2=JR(I,N2)
                                            QJI2=JI(I,N2)
                                            QDJR2=DJR(I,N2)
                                            QDJI2=DJI(I,N2)
                                            QDJ1=DJ(I,N1)
                                            QDY1=DY(I,N1)
 
                                            C1R=QJR2*QJ1
                                            C1I=QJI2*QJ1
                                            B1R=C1R-QJI2*QY1
                                            B1I=C1I+QJR2*QY1
 
                                            C2R=QJR2*QDJ1
                                            C2I=QJI2*QDJ1
                                            B2R=C2R-QJI2*QDY1
                                            B2I=C2I+QJR2*QDY1
 
                                            DDRI=DDR(I)
                                            C3R=DDRI*C1R
                                            C3I=DDRI*C1I
                                            B3R=DDRI*B1R
                                            B3I=DDRI*B1I
 
                                            C4R=QDJR2*QJ1
                                            C4I=QDJI2*QJ1
                                            B4R=C4R-QDJI2*QY1
                                            B4I=C4I+QDJR2*QY1
 
                                            DRRI=DRR(I)
                                            DRII=DRI(I)
                                            C5R=C1R*DRRI-C1I*DRII
                                            C5I=C1I*DRRI+C1R*DRII
                                            B5R=B1R*DRRI-B1I*DRII
                                            B5I=B1I*DRRI+B1R*DRII
 
                                            URI=DR(I)
                                            RRI=RR(I)
 
                                            F1=RRI*A22
                                            F2=RRI*URI*AN1*A12
                                            AR12=AR12+F1*B2R+F2*B3R
                                            AI12=AI12+F1*B2I+F2*B3I
                                            GR12=GR12+F1*C2R+F2*C3R
                                            GI12=GI12+F1*C2I+F2*C3I
 
                                            F2=RRI*URI*AN2*A21
                                            AR21=AR21+F1*B4R+F2*B5R
                                            AI21=AI21+F1*B4I+F2*B5I
                                            GR21=GR21+F1*C4R+F2*C5R
                                            GI21=GI21+F1*C4I+F2*C5I
200                                     CONTINUE
 
205                                     AN12=ANN(N1,N2)*FACTOR
                                        R12(N1,N2)=AR12*AN12
                                        R21(N1,N2)=AR21*AN12
                                        I12(N1,N2)=AI12*AN12
                                        I21(N1,N2)=AI21*AN12
                                        RG12(N1,N2)=GR12*AN12
                                        RG21(N1,N2)=GR21*AN12
                                        IG12(N1,N2)=GI12*AN12
                                        IG21(N1,N2)=GI21*AN12
300                                 CONTINUE
 
                                    TPIR=PIR
                                    TPII=PII
                                    TPPI=PPI
 
                                    NM=NMAX
                                    DO 310 N1=MM1,NMAX
                                        K1=N1-MM1+1
                                        KK1=K1+NM
                                        DO 310 N2=MM1,NMAX
                                            K2=N2-MM1+1
                                            KK2=K2+NM
 
                                            TAR12= I12(N1,N2)
                                            TAI12=-R12(N1,N2)
                                            TGR12= IG12(N1,N2)
                                            TGI12=-RG12(N1,N2)
 
                                            TAR21=-I21(N1,N2)
                                            TAI21= R21(N1,N2)
                                            TGR21=-IG21(N1,N2)
                                            TGI21= RG21(N1,N2)
 
                                            TQR(K1,K2)=TPIR*TAR21-TPII*TAI21+TPPI*TAR12
                                            TQI(K1,K2)=TPIR*TAI21+TPII*TAR21+TPPI*TAI12
                                            TRGQR(K1,K2)=TPIR*TGR21-TPII*TGI21+TPPI*TGR12
                                            TRGQI(K1,K2)=TPIR*TGI21+TPII*TGR21+TPPI*TGI12
 
                                            TQR(K1,KK2)=0D0
                                            TQI(K1,KK2)=0D0
                                            TRGQR(K1,KK2)=0D0
                                            TRGQI(K1,KK2)=0D0
 
                                            TQR(KK1,K2)=0D0
                                            TQI(KK1,K2)=0D0
                                            TRGQR(KK1,K2)=0D0
                                            TRGQI(KK1,K2)=0D0
 
                                            TQR(KK1,KK2)=TPIR*TAR12-TPII*TAI12+TPPI*TAR21
                                            TQI(KK1,KK2)=TPIR*TAI12+TPII*TAR12+TPPI*TAI21
                                            TRGQR(KK1,KK2)=TPIR*TGR12-TPII*TGI12+TPPI*TGR21
                                            TRGQI(KK1,KK2)=TPIR*TGI12+TPII*TGR12+TPPI*TGI21
310                                     CONTINUE
 
                                        NNMAX=2*NM
                                        DO 320 N1=1,NNMAX
                                            DO 320 N2=1,NNMAX
                                                QR(N1,N2)=TQR(N1,N2)
                                                QI(N1,N2)=TQI(N1,N2)
                                                RGQR(N1,N2)=TRGQR(N1,N2)
                                                RGQI(N1,N2)=TRGQI(N1,N2)
320                                         CONTINUE
                                            CALL TT(NMAX,NCHECK)
                                            RETURN
                                        END
 
                                        !**********************************************************************
 
                                        SUBROUTINE TMATR (M,NGAUSS,X,W,AN,ANN,S,SS,PPI,PIR,PII,R,DR,DDR,&
                                        DRR,DRI,NMAX,NCHECK)
                                            !      INCLUDE 'ampld.par.f'
                                            Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1, &
                                            NPL=NPN2+1, NPN3=NPN1+1, &
                                            NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                                            IMPLICIT REAL*8 (A-H,O-Z)
                                            REAL*8  X(NPNG2),W(NPNG2),AN(NPN1),S(NPNG2),SS(NPNG2),&
                                            R(NPNG2),DR(NPNG2),SIG(NPN2),&
                                            J(NPNG2,NPN1),Y(NPNG2,NPN1),&
                                            JR(NPNG2,NPN1),JI(NPNG2,NPN1),DJ(NPNG2,NPN1),&
                                            DY(NPNG2,NPN1),DJR(NPNG2,NPN1),&
                                            DJI(NPNG2,NPN1),DDR(NPNG2),DRR(NPNG2),&
                                            D1(NPNG2,NPN1),D2(NPNG2,NPN1),&
                                            DRI(NPNG2),DS(NPNG2),DSS(NPNG2),RR(NPNG2),&
                                            DV1(NPN1),DV2(NPN1)
 
                                            REAL*8  R11(NPN1,NPN1),R12(NPN1,NPN1),&
                                            R21(NPN1,NPN1),R22(NPN1,NPN1),&
                                            I11(NPN1,NPN1),I12(NPN1,NPN1),&
                                            I21(NPN1,NPN1),I22(NPN1,NPN1),&
                                            RG11(NPN1,NPN1),RG12(NPN1,NPN1),&
                                            RG21(NPN1,NPN1),RG22(NPN1,NPN1),&
                                            IG11(NPN1,NPN1),IG12(NPN1,NPN1),&
                                            IG21(NPN1,NPN1),IG22(NPN1,NPN1),&
                                            ANN(NPN1,NPN1),&
                                            QR(NPN2,NPN2),QI(NPN2,NPN2),&
                                            RGQR(NPN2,NPN2),RGQI(NPN2,NPN2),&
                                            TQR(NPN2,NPN2),TQI(NPN2,NPN2),&
                                            TRGQR(NPN2,NPN2),TRGQI(NPN2,NPN2)
                                            REAL*8 TR1(NPN2,NPN2),TI1(NPN2,NPN2)
                                            COMMON /TMAT99/ &
                                            R11,R12,R21,R22,I11,I12,I21,I22,RG11,RG12,RG21,RG22,&
                                            IG11,IG12,IG21,IG22
                                            COMMON /CBESS/ J,Y,JR,JI,DJ,DY,DJR,DJI
                                            COMMON /CT/ TR1,TI1
                                            COMMON /CTT/ QR,QI,RGQR,RGQI
                                            MM1=M
                                            QM=DFLOAT(M)
                                            QMM=QM*QM
                                            NG=2*NGAUSS
                                            NGSS=NG
                                            FACTOR=1D0
                                            IF (NCHECK.EQ.1) THEN
                                                NGSS=NGAUSS
                                                FACTOR=2D0
                                            ELSE
                                            CONTINUE
                                        ENDIF
                                        SI=1D0
                                        NM=NMAX+NMAX
                                        DO 5 N=1,NM
                                            SI=-SI
                                            SIG(N)=SI
5                                       CONTINUE
                                        20 DO 25 I=1,NGAUSS
                                            I1=NGAUSS+I
                                            I2=NGAUSS-I+1
                                            CALL VIG (X(I1),NMAX,M,DV1,DV2)
                                            DO 25 N=1,NMAX
                                                SI=SIG(N)
                                                DD1=DV1(N)
                                                DD2=DV2(N)
                                                D1(I1,N)=DD1
                                                D2(I1,N)=DD2
                                                D1(I2,N)=DD1*SI
                                                D2(I2,N)=-DD2*SI
25                                          CONTINUE
                                            30 DO 40 I=1,NGSS
                                                WR=W(I)*R(I)
                                                DS(I)=S(I)*QM*WR
                                                DSS(I)=SS(I)*QMM
                                                RR(I)=WR
40                                          CONTINUE
 
                                            DO 300  N1=MM1,NMAX
                                                AN1=AN(N1)
                                                DO 300 N2=MM1,NMAX
                                                    AN2=AN(N2)
                                                    AR11=0D0
                                                    AR12=0D0
                                                    AR21=0D0
                                                    AR22=0D0
                                                    AI11=0D0
                                                    AI12=0D0
                                                    AI21=0D0
                                                    AI22=0D0
                                                    GR11=0D0
                                                    GR12=0D0
                                                    GR21=0D0
                                                    GR22=0D0
                                                    GI11=0D0
                                                    GI12=0D0
                                                    GI21=0D0
                                                    GI22=0D0
                                                    SI=SIG(N1+N2)
 
                                                    DO 200 I=1,NGSS
                                                        D1N1=D1(I,N1)
                                                        D2N1=D2(I,N1)
                                                        D1N2=D1(I,N2)
                                                        D2N2=D2(I,N2)
                                                        A11=D1N1*D1N2
                                                        A12=D1N1*D2N2
                                                        A21=D2N1*D1N2
                                                        A22=D2N1*D2N2
                                                        AA1=A12+A21
                                                        AA2=A11*DSS(I)+A22
                                                        QJ1=J(I,N1)
                                                        QY1=Y(I,N1)
                                                        QJR2=JR(I,N2)
                                                        QJI2=JI(I,N2)
                                                        QDJR2=DJR(I,N2)
                                                        QDJI2=DJI(I,N2)
                                                        QDJ1=DJ(I,N1)
                                                        QDY1=DY(I,N1)
 
                                                        C1R=QJR2*QJ1
                                                        C1I=QJI2*QJ1
                                                        B1R=C1R-QJI2*QY1
                                                        B1I=C1I+QJR2*QY1
 
                                                        C2R=QJR2*QDJ1
                                                        C2I=QJI2*QDJ1
                                                        B2R=C2R-QJI2*QDY1
                                                        B2I=C2I+QJR2*QDY1
 
                                                        DDRI=DDR(I)
                                                        C3R=DDRI*C1R
                                                        C3I=DDRI*C1I
                                                        B3R=DDRI*B1R
                                                        B3I=DDRI*B1I
 
                                                        C4R=QDJR2*QJ1
                                                        C4I=QDJI2*QJ1
                                                        B4R=C4R-QDJI2*QY1
                                                        B4I=C4I+QDJR2*QY1
 
                                                        DRRI=DRR(I)
                                                        DRII=DRI(I)
                                                        C5R=C1R*DRRI-C1I*DRII
                                                        C5I=C1I*DRRI+C1R*DRII
                                                        B5R=B1R*DRRI-B1I*DRII
                                                        B5I=B1I*DRRI+B1R*DRII
 
                                                        C6R=QDJR2*QDJ1
                                                        C6I=QDJI2*QDJ1
                                                        B6R=C6R-QDJI2*QDY1
                                                        B6I=C6I+QDJR2*QDY1
 
                                                        C7R=C4R*DDRI
                                                        C7I=C4I*DDRI
                                                        B7R=B4R*DDRI
                                                        B7I=B4I*DDRI
 
                                                        C8R=C2R*DRRI-C2I*DRII
                                                        C8I=C2I*DRRI+C2R*DRII
                                                        B8R=B2R*DRRI-B2I*DRII
                                                        B8I=B2I*DRRI+B2R*DRII
 
                                                        URI=DR(I)
                                                        DSI=DS(I)
                                                        DSSI=DSS(I)
                                                        RRI=RR(I)
 
                                                        IF (NCHECK.EQ.1.AND.SI.GT.0D0) GO TO 150
 
                                                        E1=DSI*AA1
                                                        AR11=AR11+E1*B1R
                                                        AI11=AI11+E1*B1I
                                                        GR11=GR11+E1*C1R
                                                        GI11=GI11+E1*C1I
                                                        IF (NCHECK.EQ.1) GO TO 160
 
150                                                     F1=RRI*AA2
                                                        F2=RRI*URI*AN1*A12
                                                        AR12=AR12+F1*B2R+F2*B3R
                                                        AI12=AI12+F1*B2I+F2*B3I
                                                        GR12=GR12+F1*C2R+F2*C3R
                                                        GI12=GI12+F1*C2I+F2*C3I
 
                                                        F2=RRI*URI*AN2*A21
                                                        AR21=AR21+F1*B4R+F2*B5R
                                                        AI21=AI21+F1*B4I+F2*B5I
                                                        GR21=GR21+F1*C4R+F2*C5R
                                                        GI21=GI21+F1*C4I+F2*C5I
                                                        IF (NCHECK.EQ.1) GO TO 200
 
160                                                     E2=DSI*URI*A11
                                                        E3=E2*AN2
                                                        E2=E2*AN1
                                                        AR22=AR22+E1*B6R+E2*B7R+E3*B8R
                                                        AI22=AI22+E1*B6I+E2*B7I+E3*B8I
                                                        GR22=GR22+E1*C6R+E2*C7R+E3*C8R
                                                        GI22=GI22+E1*C6I+E2*C7I+E3*C8I
200                                                 CONTINUE
                                                    AN12=ANN(N1,N2)*FACTOR
                                                    R11(N1,N2)=AR11*AN12
                                                    R12(N1,N2)=AR12*AN12
                                                    R21(N1,N2)=AR21*AN12
                                                    R22(N1,N2)=AR22*AN12
                                                    I11(N1,N2)=AI11*AN12
                                                    I12(N1,N2)=AI12*AN12
                                                    I21(N1,N2)=AI21*AN12
                                                    I22(N1,N2)=AI22*AN12
                                                    RG11(N1,N2)=GR11*AN12
                                                    RG12(N1,N2)=GR12*AN12
                                                    RG21(N1,N2)=GR21*AN12
                                                    RG22(N1,N2)=GR22*AN12
                                                    IG11(N1,N2)=GI11*AN12
                                                    IG12(N1,N2)=GI12*AN12
                                                    IG21(N1,N2)=GI21*AN12
                                                    IG22(N1,N2)=GI22*AN12
 
300                                             CONTINUE
                                                TPIR=PIR
                                                TPII=PII
                                                TPPI=PPI
                                                NM=NMAX-MM1+1
                                                DO 310 N1=MM1,NMAX
                                                    K1=N1-MM1+1
                                                    KK1=K1+NM
                                                    DO 310 N2=MM1,NMAX
                                                        K2=N2-MM1+1
                                                        KK2=K2+NM
 
                                                        TAR11=-R11(N1,N2)
                                                        TAI11=-I11(N1,N2)
                                                        TGR11=-RG11(N1,N2)
                                                        TGI11=-IG11(N1,N2)
 
                                                        TAR12= I12(N1,N2)
                                                        TAI12=-R12(N1,N2)
                                                        TGR12= IG12(N1,N2)
                                                        TGI12=-RG12(N1,N2)
 
                                                        TAR21=-I21(N1,N2)
                                                        TAI21= R21(N1,N2)
                                                        TGR21=-IG21(N1,N2)
                                                        TGI21= RG21(N1,N2)
 
                                                        TAR22=-R22(N1,N2)
                                                        TAI22=-I22(N1,N2)
                                                        TGR22=-RG22(N1,N2)
                                                        TGI22=-IG22(N1,N2)
 
                                                        TQR(K1,K2)=TPIR*TAR21-TPII*TAI21+TPPI*TAR12
                                                        TQI(K1,K2)=TPIR*TAI21+TPII*TAR21+TPPI*TAI12
                                                        TRGQR(K1,K2)=TPIR*TGR21-TPII*TGI21+TPPI*TGR12
                                                        TRGQI(K1,K2)=TPIR*TGI21+TPII*TGR21+TPPI*TGI12
 
                                                        TQR(K1,KK2)=TPIR*TAR11-TPII*TAI11+TPPI*TAR22
                                                        TQI(K1,KK2)=TPIR*TAI11+TPII*TAR11+TPPI*TAI22
                                                        TRGQR(K1,KK2)=TPIR*TGR11-TPII*TGI11+TPPI*TGR22
                                                        TRGQI(K1,KK2)=TPIR*TGI11+TPII*TGR11+TPPI*TGI22
 
                                                        TQR(KK1,K2)=TPIR*TAR22-TPII*TAI22+TPPI*TAR11
                                                        TQI(KK1,K2)=TPIR*TAI22+TPII*TAR22+TPPI*TAI11
                                                        TRGQR(KK1,K2)=TPIR*TGR22-TPII*TGI22+TPPI*TGR11
                                                        TRGQI(KK1,K2)=TPIR*TGI22+TPII*TGR22+TPPI*TGI11
 
                                                        TQR(KK1,KK2)=TPIR*TAR12-TPII*TAI12+TPPI*TAR21
                                                        TQI(KK1,KK2)=TPIR*TAI12+TPII*TAR12+TPPI*TAI21
                                                        TRGQR(KK1,KK2)=TPIR*TGR12-TPII*TGI12+TPPI*TGR21
                                                        TRGQI(KK1,KK2)=TPIR*TGI12+TPII*TGR12+TPPI*TGI21
310                                                 CONTINUE
 
                                                    NNMAX=2*NM
                                                    DO 320 N1=1,NNMAX
                                                        DO 320 N2=1,NNMAX
                                                            QR(N1,N2)=TQR(N1,N2)
                                                            QI(N1,N2)=TQI(N1,N2)
                                                            RGQR(N1,N2)=TRGQR(N1,N2)
                                                            RGQI(N1,N2)=TRGQI(N1,N2)
320                                                     CONTINUE
 
                                                        CALL TT(NM,NCHECK)
 
                                                        RETURN
                                                    END
 
                                                    !*****************************************************************
 
                                                    SUBROUTINE VIG (X, NMAX, M, DV1, DV2)
                                                        !      INCLUDE 'ampld.par.f'
                                                        Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1,  &
                                                        NPL=NPN2+1, NPN3=NPN1+1,  &
                                                        NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                                                        IMPLICIT REAL*8 (A-H,O-Z)
                                                        REAL*8 DV1(NPN1),DV2(NPN1)
 
                                                        A=1D0
                                                        QS=DSQRT(1D0-X*X)
                                                        QS1=1D0/QS
                                                        DO N=1,NMAX
                                                            DV1(N)=0D0
                                                            DV2(N)=0D0
                                                        ENDDO
                                                        IF (M.NE.0) GO TO 20
                                                        D1=1D0
                                                        D2=X
                                                        DO N=1,NMAX
                                                            QN=DFLOAT(N)
                                                            QN1=DFLOAT(N+1)
                                                            QN2=DFLOAT(2*N+1)
                                                            D3=(QN2*X*D2-QN*D1)/QN1
                                                            DER=QS1*(QN1*QN/QN2)*(-D1+D3)
                                                            DV1(N)=D2
                                                            DV2(N)=DER
                                                            D1=D2
                                                            D2=D3
                                                        ENDDO
                                                        RETURN
20                                                      QMM=DFLOAT(M*M)
                                                        DO I=1,M
                                                            I2=I*2
                                                            A=A*DSQRT(DFLOAT(I2-1)/DFLOAT(I2))*QS
                                                        ENDDO
                                                        D1=0D0
                                                        D2=A
                                                        DO N=M,NMAX
                                                            QN=DFLOAT(N)
                                                            QN2=DFLOAT(2*N+1)
                                                            QN1=DFLOAT(N+1)
                                                            QNM=DSQRT(QN*QN-QMM)
                                                            QNM1=DSQRT(QN1*QN1-QMM)
                                                            D3=(QN2*X*D2-QNM*D1)/QNM1
                                                            DER=QS1*(-QN1*QNM*D1+QN*QNM1*D3)/QN2
                                                            DV1(N)=D2
                                                            DV2(N)=DER
                                                            D1=D2
                                                            D2=D3
                                                        ENDDO
                                                        RETURN
                                                    END
 
                                                    !**********************************************************************
                                                    !                                                                     *
                                                    !   CALCULATION OF THE MATRIX    T = - RG(Q) * (Q**(-1))              *
                                                    !                                                                     *
                                                    !   INPUT INFORTMATION IS IN COMMON /CTT/                             *
                                                    !   OUTPUT INFORMATION IS IN COMMON /CT/                              *
                                                    !                                                                     *
                                                    !**********************************************************************
 
                                                    SUBROUTINE TT(NMAX,NCHECK)
                                                        !      INCLUDE 'ampld.par.f'
                                                        Parameter (NPN1=100, NPNG1=500, NPNG2=2*NPNG1, NPN2=2*NPN1,&
                                                        NPL=NPN2+1, NPN3=NPN1+1,&
                                                        NPN4=NPN1, NPN5=2*NPN4, NPN6=NPN4+1)

                                                        IMPLICIT REAL*8 (A-H,O-Z)
                                                        REAL*8 F(NPN2,NPN2),B(NPN2),WORK(NPN2),&
                                                        QR(NPN2,NPN2),QI(NPN2,NPN2),&
                                                        RGQR(NPN2,NPN2),RGQI(NPN2,NPN2),&
                                                        A(NPN2,NPN2),C(NPN2,NPN2),D(NPN2,NPN2),E(NPN2,NPN2)
                                                        REAL*8 TR1(NPN2,NPN2),TI1(NPN2,NPN2)
                                                        COMPLEX*16 ZQ(NPN2,NPN2),ZW(NPN2)
                                                        INTEGER IPIV(NPN2),IPVT(NPN2)
                                                        COMMON /CT/ TR1,TI1
                                                        COMMON /CTT/ QR,QI,RGQR,RGQI
                                                        NDIM=NPN2
                                                        NNMAX=2*NMAX

                                                        !     Matrix inversion from LAPACK

                                                        DO I=1,NNMAX
                                                            DO J=1,NNMAX
                                                                ZQ(I,J)=DCMPLX(QR(I,J),QI(I,J))
                                                            ENDDO
                                                        ENDDO
                                                        INFO=0
                                                        CALL ZGETRF(NNMAX,NNMAX,ZQ,NPN2,IPIV,INFO)
                                                        IF (INFO.NE.0) WRITE (6,1100) INFO
                                                        CALL ZGETRI(NNMAX,ZQ,NPN2,IPIV,ZW,NPN2,INFO)
                                                        IF (INFO.NE.0) WRITE (6,1100) INFO

1100                                                    FORMAT ('WARNING:  info=', i2)
                                                        DO I=1,NNMAX
                                                            DO J=1,NNMAX
                                                                TR=0D0
                                                                TI=0D0
                                                                DO K=1,NNMAX
                                                                    ARR=RGQR(I,K)
                                                                    ARI=RGQI(I,K)
                                                                    AR=ZQ(K,J)
                                                                    AI=DIMAG(ZQ(K,J))
                                                                    TR=TR-ARR*AR+ARI*AI
                                                                    TI=TI-ARR*AI-ARI*AR
                                                                ENDDO
                                                                TR1(I,J)=TR
                                                                TI1(I,J)=TI
                                                            ENDDO
                                                        ENDDO
                                                        RETURN
                                                    END

                                                    !*****************************************************************
 
                                                    SUBROUTINE SAREA (D,RAT)
                                                        IMPLICIT REAL*8 (A-H,O-Z)
                                                        IF (D.GE.1) GO TO 10
                                                        E=DSQRT(1D0-D*D)
                                                        R=0.5D0*(D**(2D0/3D0) + D**(-1D0/3D0)*DASIN(E)/E)
                                                        R=DSQRT(R)
                                                        RAT=1D0/R
                                                        RETURN
10                                                      E=DSQRT(1D0-1D0/(D*D))
                                                        R=0.25D0*(2D0*D**(2D0/3D0) + D**(-4D0/3D0)*DLOG((1D0+E)/(1D0-E))&
                                                        /E)
                                                        R=DSQRT(R)
                                                        RAT=1D0/R
                                                        return
                                                    END
 
                                                    !****************************************************************
 
                                                    SUBROUTINE SURFCH (N,E,RAT)
                                                        IMPLICIT REAL*8 (A-H,O-Z)
                                                        REAL*8 X(60),W(60)
                                                        DN=DFLOAT(N)
                                                        E2=E*E
                                                        EN=E*DN
                                                        NG=60
                                                        CALL GAUSS (NG,0,0,X,W)
                                                        S=0D0
                                                        V=0D0
                                                        DO 10 I=1,NG
                                                            XI=X(I)
                                                            DX=DACOS(XI)
                                                            DXN=DN*DX
                                                            DS=DSIN(DX)
                                                            DSN=DSIN(DXN)
                                                            DCN=DCOS(DXN)
                                                            A=1D0+E*DCN
                                                            A2=A*A
                                                            ENS=EN*DSN
                                                            S=S+W(I)*A*DSQRT(A2+ENS*ENS)
                                                            V=V+W(I)*(DS*A+XI*ENS)*DS*A2
10                                                      CONTINUE
                                                        RS=DSQRT(S*0.5D0)
                                                        RV=(V*3D0/4D0)**(1D0/3D0)
                                                        RAT=RV/RS
                                                        RETURN
                                                    END
 
                                                    !********************************************************************
 
                                                    SUBROUTINE SAREAC (EPS,RAT)
                                                        IMPLICIT REAL*8 (A-H,O-Z)
                                                        RAT=(1.5D0/EPS)**(1D0/3D0)
                                                        RAT=RAT/DSQRT( (EPS+2D0)/(2D0*EPS) )
                                                        RETURN
                                                    END

                                                    !**********************************************************************

                                                    SUBROUTINE DROP (RAT)
                                                        PARAMETER (NC=10, NG=60)
                                                        IMPLICIT REAL*8 (A-H,O-Z)
                                                        REAL*8 X(NG),W(NG),C(0:NC)
                                                        COMMON /CDROP/ C,R0V
                                                        C(0)=-0.0481D0
                                                        C(1)= 0.0359D0
                                                        C(2)=-0.1263D0
                                                        C(3)= 0.0244D0
                                                        C(4)= 0.0091D0
                                                        C(5)=-0.0099D0
                                                        C(6)= 0.0015D0
                                                        C(7)= 0.0025D0
                                                        C(8)=-0.0016D0
                                                        C(9)=-0.0002D0
                                                        C(10)= 0.0010D0
                                                        CALL GAUSS (NG,0,0,X,W)
                                                        S=0D0
                                                        V=0D0
                                                        DO I=1,NG
                                                            XI=DACOS(X(I))
                                                            WI=W(I)
                                                            RI=1D0+C(0)
                                                            DRI=0D0
                                                            DO N=1,NC
                                                                XIN=XI*N
                                                                RI=RI+C(N)*DCOS(XIN)
                                                                DRI=DRI-C(N)*N*DSIN(XIN)
                                                            ENDDO
                                                            SI=DSIN(XI)
                                                            CI=X(I)
                                                            RISI=RI*SI
                                                            S=S+WI*RI*DSQRT(RI*RI+DRI*DRI)
                                                            V=V+WI*RI*RISI*(RISI-DRI*CI)
                                                        ENDDO
                                                        RS=DSQRT(S*0.5D0)
                                                        RV=(V*3D0*0.25D0)**(1D0/3D0)
                                                        IF (DABS(RAT-1D0).GT.1D-8) RAT=RV/RS
                                                        R0V=1D0/RV
                                                        WRITE (6,1000) R0V
                                                        DO N=0,NC
                                                            WRITE (6,1001) N,C(N)
                                                        ENDDO
1000                                                    FORMAT ('r_0/r_ev=',F7.4)
1001                                                    FORMAT ('c_',I2,'=',F7.4)
                                                        RETURN
                                                    END

                                                    !**********************************************************************
                                                    !    CALCULATION OF POINTS AND WEIGHTS OF GAUSSIAN QUADRATURE         *
                                                    !    FORMULA. IF IND1 = 0 - ON INTERVAL (-1,1), IF IND1 = 1 - ON      *
                                                    !    INTERVAL  (0,1). IF  IND2 = 1 RESULTS ARE PRINTED.               *
                                                    !    N - NUMBER OF POINTS                                             *
                                                    !    Z - DIVISION POINTS                                              *
                                                    !    W - WEIGHTS                                                      *
                                                    !**********************************************************************
 
                                                    SUBROUTINE GAUSS (N,IND1,IND2,Z,W)
                                                        IMPLICIT REAL*8 (A-H,P-Z)
                                                        REAL*8 Z(N),W(N)
                                                        A=1D0
                                                        B=2D0
                                                        C=3D0
                                                        IND=MOD(N,2)
                                                        K=N/2+IND
                                                        F=DFLOAT(N)
                                                        DO 100 I=1,K
                                                            M=N+1-I
                                                            IF(I.EQ.1) X=A-B/((F+A)*F)
                                                            IF(I.EQ.2) X=(Z(N)-A)*4D0+Z(N)
                                                            IF(I.EQ.3) X=(Z(N-1)-Z(N))*1.6D0+Z(N-1)
                                                            IF(I.GT.3) X=(Z(M+1)-Z(M+2))*C+Z(M+3)
                                                            IF(I.EQ.K.AND.IND.EQ.1) X=0D0
                                                            NITER=0
                                                            CHECK=1D-16
10                                                          PB=1D0
                                                            NITER=NITER+1
                                                            IF (NITER.LE.100) GO TO 15
                                                            CHECK=CHECK*10D0
15                                                          PC=X
                                                            DJ=A
                                                            DO 20 J=2,N
                                                                DJ=DJ+A
                                                                PA=PB
                                                                PB=PC
20                                                              PC=X*PB+(X*PB-PA)*(DJ-A)/DJ
                                                                PA=A/((PB-X*PC)*F)
                                                                PB=PA*PC*(A-X*X)
                                                                X=X-PB
                                                                IF(DABS(PB).GT.CHECK*DABS(X)) GO TO 10
                                                                Z(M)=X
                                                                W(M)=PA*PA*(A-X*X)
                                                                IF(IND1.EQ.0) W(M)=B*W(M)
                                                                IF(I.EQ.K.AND.IND.EQ.1) GO TO 100
                                                                Z(I)=-Z(M)
                                                                W(I)=W(M)
100                                                         CONTINUE
                                                            IF(IND2.NE.1) GO TO 110
                                                            PRINT 1100,N
1100                                                        FORMAT(' ***  POINTS AND WEIGHTS OF GAUSSIAN QUADRATURE FORMULA',&
                                                            ' OF ',I4,'-TH ORDER')
                                                            DO 105 I=1,K
                                                                ZZ=-Z(I)
105                                                             PRINT 1200,I,ZZ,I,W(I)
1200                                                            FORMAT(' ',4X,'X(',I4,') = ',F17.14,5X,'W(',I4,') = ',F17.14)
                                                                GO TO 115
110                                                         CONTINUE
                                                            !     PRINT 1300,N
1300                                                        FORMAT(' GAUSSIAN QUADRATURE FORMULA OF ',I4,'-TH ORDER IS USED')
115                                                     CONTINUE
                                                        IF(IND1.EQ.0) GO TO 140
                                                        DO 120 I=1,N
120                                                         Z(I)=(A+Z(I))/B
140                                                     CONTINUE
                                                        RETURN
                                                    END
