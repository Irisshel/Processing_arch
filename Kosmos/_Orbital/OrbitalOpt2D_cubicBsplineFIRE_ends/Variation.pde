

// Gauss-Legendre 6 // Gauss-Legendre converge fastest on test functions, for polynoms of degree <=6 6 points gives exact integral
final static double [] IntegrationNodes   ={0.96623475710157603d, 0.83060469323313224d, 0.61930959304159838d, 0.38069040695840151d, 0.1693953067668677d, 0.033765242898423975d};
final static double [] IntegrationWeights ={0.085662246189585275d, 0.18038078652406944d, 0.23395696728634541d, 0.23395696728634555d, 0.18038078652406908d, 0.085662246189584831d};

/*

 Tx   = cx*ddx - Gx(x,y)
 Ty   = cy*ddy - Gy(x,y)
 x_cx = bx 
 
 ( Tx^2 + Ty^2 )_cx1 = Tx*( ddx - Gx_x * x_cx    )  + Ty*( 0 - Gy_x * x_cx  )
                     = Tx*( ddx - Gx_x * bx      )  + Ty*( 0 - Gy_x * bx    )

*/



void getDerivs( double [][] Cs, double [][] dCs, boolean plot ){
  for (int i=0;i<ncoef;i++){ dCs[0][i]=0; dCs[1][i]=0; }
  double sumT2  = 0;
  
  for (int i=3;i<ncoef;i++){ 
    final double i6 = 1.0d/6.0d;
    double cx0 = Cs[0][i  ];
    double cx1 = Cs[0][i-1]; 
    double cx2 = Cs[0][i-2];
    double cx3 = Cs[0][i-3];
    
    double cy0 = Cs[1][i  ];
    double cy1 = Cs[1][i-1]; 
    double cy2 = Cs[1][i-2];
    double cy3 = Cs[1][i-3];
    
    double fx0 = 0,fx1=0,fx2=0,fx3=0; 
    double fy0 = 0,fy1=0,fy2=0,fy3=0; 
    for (int iu=0; iu<IntegrationNodes.length; iu++){
      double      u =  IntegrationNodes[iu];
      double      w =  IntegrationWeights[iu];
      
      // Evaluate Gravity 
      double u2  = u*u; double u3 = u2*u;
      double b0  = i6*(                    u3 );
      double b1  = i6*( 1 + 3*u + 3*u2 - 3*u3 );
      double b2  = i6*( 4       - 6*u2 + 3*u3 );
      double b3  = i6*( 1 - 3*u + 3*u2 -   u3 );
      
      double x   = cx0*b0 + cx1*b1 + cx2*b2 + cx3*b3; 
      double y   = cy0*b0 + cy1*b1 + cy2*b2 + cy3*b3;
      double ir2 = 1.0d/( x*x + y*y );
      double ir  = Math.sqrt( ir2 );
      double ir3 =  ir2*ir;
      double Gx  =  x*ir3;
      double Gy  =  y*ir3;
      
      double Gx_x  =  3*x*Gx*ir2 - ir3;
      double Gx_y  =  3*y*Gx*ir2;
      double Gy_y  =  3*y*Gy*ir2 - ir3;
      double Gy_x  =  3*x*Gy*ir2;
      
      // evauleate acceleration
      double ddb0 = i6*(       6*u)*u_t2;   
      double ddb1 = i6*(  6 - 18*u)*u_t2;   
      double ddb2 = i6*(-12 + 18*u)*u_t2;   
      double ddb3 = i6*(  6 -  6*u)*u_t2; 
      double ddx  = cx0*ddb0 + cx1*ddb1 + cx2*ddb2 + cx3*ddb3; 
      double ddy  = cy0*ddb0 + cy1*ddb1 + cy2*ddb2 + cy3*ddb3;

      // put i all together
      double Tx   = ddx + Gx;
      double Ty   = ddy + Gy; 
      
      // correction of boundary conditions
      if(i<5){
        if(i==4){
          b1   += 0.5*  b0;
          ddb1 += 0.5*ddb0;
        }else{
          b2   += 0.5*  b1  -   b0;
          ddb2 += 0.5*ddb1  - ddb0;
        }  
      }else 
      if( i>ncoef-3 ){
        if(i==ncoef-2){
          //b1   += 0.5*  b0;
          //ddb1 += 0.5*ddb0;
          b2   += 0.5*  b3;
          ddb2 += 0.5*ddb3;
        }else{
          b1   += 0.5*  b2  +   b3;
          ddb1 += 0.5*ddb2  + ddb3;
          //b2   += 0.5*  b1  +   b0;
          //ddb2 += 0.5*ddb1  + ddb0;
        } 
      
      }
            
      sumT2+= w*( Tx*Tx + Ty*Ty );
      double T2_ddbx =  2*w*  Tx                 ; 
      double T2_bx   = -2*w*( Tx*Gx_x + Ty*Gy_x );
      fx0+= T2_ddbx * ddb0 + T2_bx * b0;
      fx1+= T2_ddbx * ddb1 + T2_bx * b1;
      fx2+= T2_ddbx * ddb2 + T2_bx * b2;
      fx3+= T2_ddbx * ddb3 + T2_bx * b3;
      double T2_ddby = 2*w*  Ty                 ; 
      double T2_by   = -2*w*( Tx*Gx_y + Ty*Gy_y );
      fy0+= T2_ddby * ddb0 + T2_by * b0;
      fy1+= T2_ddby * ddb1 + T2_by * b1;
      fy2+= T2_ddby * ddb2 + T2_by * b2;
      fy3+= T2_ddby * ddb3 + T2_by * b3;
      
      if(plot){
        //println( i+" "+iu+" "+x+" "+y+" "+Gx+" "+Gy );
        stroke(0,0,255); line( sx(x),sx(y),   sx(x-Gx*0.1),  sx(y-Gy*0.1)   );
        stroke(0,255,0); line( sx(x),sx(y),   sx(x-ddx*0.1), sx(y-ddy*0.1)  );
        stroke(255,0,0); line( sx(x),sx(y),   sx(x-Tx*0.1),  sx(y-Ty*0.1)   );
      }
    }
    
    dCs[0][i  ] -= fx0;
    dCs[0][i-1] -= fx1;
    dCs[0][i-2] -= fx2;
    dCs[0][i-3] -= fx3;
    
    dCs[1][i  ] -= fy0;
    dCs[1][i-1] -= fy1;
    dCs[1][i-2] -= fy2;
    dCs[1][i-3] -= fy3;
  }
  T2tot  = sumT2;
}
