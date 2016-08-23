( function _RegExp_test_s( ) {

  'use strict';

  /*

   to run this test
   from the project directory run

   npm install
   node ./staging/z.tests/RegExp.test.s

   */

  if( typeof module !== 'undefined' )
  {

    require( '../wTools.s' );

    if( require( 'fs' ).existsSync( __dirname + '/../object/Testing.debug.s' ) )
    require( '../object/Testing.debug.s' );
    else
    require( 'wTesting' );

  }

  var _ = wTools;
  var Self = {};

  // shared variables
  var ArrOfRegx1 = [ /0/, /1/, /2/ ],
    ArrOfRegx2 = [ /3/, /4/, /5/ ],
    ArrOfRegx3 = [ /6/, /7/, /8/ ],
    ArrOfRegx4 = [ /9/, /10/, /11/ ],
    ArrOfRegx5 = [ /12/, /13/, /14/ ],
    ArrOfRegx6 = [ /14/, /16/, /17/ ],
    ArrOfRegx7 = [ /18/, /19/, /20/ ],
    ArrOfRegx8 = [ /21/, /22/, /23/ ],

    src1 =
    {
      includeAny: ArrOfRegx1,
      includeAll: ArrOfRegx2,
      excludeAny: ArrOfRegx3,
      excludeAll: ArrOfRegx4
    },
    src2 =
    {
      includeAny: ArrOfRegx5,
      includeAll: ArrOfRegx6,
      excludeAny: ArrOfRegx7,
      excludeAll: ArrOfRegx8
    },
    src3 =
    {
      includeAny: [ /a0/, /a1/, /a2/ ],
      includeAll: [ /b0/, /c1/, /c2/ ],
      excludeAny: [ /c0/, /c1/, /c2/ ],
      excludeAll: [ /d0/, /d1/, /d2/ ]
    },
    wrongSrc =
    {
      includeAny: ArrOfRegx5,
      includeAll: ArrOfRegx6,
      excludeAny: ArrOfRegx7,
      excludeAll: ArrOfRegx8,
      excludeSome: [ /[^a]/ ]
    };

  var getSource = function( v )
  {
    return (typeof v === 'string') ? v : v.source;
  };

  var getSourceFromMap = function(resultObj)
  {
    var i;
    for( i in resultObj )
    resultObj.hasOwnProperty( i ) && (resultObj[ i ] = resultObj[ i ].map( getSource ));
  };

//

  var regexpEscape = function( test )
  {
    var simpleStr = 'hello world',
      specialCharacters = '.*+?^=!:${}()|[]/\\',
      simpleSent = 'Hello. How are you?',
      empty = '';

    var expected1 = '\\.\\*\\+\\?\\^\\=\\!\\:\\$\\{\\}\\(\\)\\|\\[\\]\\/\\\\',
      expected2 = "Hello\\. How are you\\?"

    test.description = 'escape simple str without spec. characters';
    var got = _.regexpEscape( simpleStr );
    test.identical( got, simpleStr );

    test.description = 'escape special characters';
    var got = _.regexpEscape( specialCharacters );
    test.identical( got, expected1 );

    test.description = 'escape simple sentences';
    var got = _.regexpEscape( simpleSent );
    test.identical( got, expected2 );

    test.description = 'escape empty string';
    var got = _.regexpEscape( empty );
    test.identical( got, empty );
  };

//

  var regexpForGlob = function( test )
  {
    var globSample1 = '*.txt',
      globSample2 = '*.*',
      globSample3 = '??',
      globSample4 = '**',
      globSample5 = 'subdir/img*/th_?';

    var expected1 = /^.\/[^\/]*\.txt$/m,
      expected2 = /^.\/[^\/]*\.[^\/]*$/m,
      expected3 = /^.\/..$/m,
      expected4 = /^.\/.*$/m,
      expected5 = /^.\/subdir\/img[^\/]*\/th_.$/m;

    test.description = 'pattern for all .txt files in directory';
    var got = _.regexpForGlob( globSample1 );
    test.identical( got.source, expected1.source );

    test.description = 'pattern for all files in directory';
    var got = _.regexpForGlob( globSample2 );
    test.identical( got.source, expected2.source );

    test.description = 'pattern for exactly two characters in length file names';
    var got = _.regexpForGlob( globSample3 );
    test.identical( got.source, expected3.source );

    test.description = 'pattern for all files and directories';
    var got = _.regexpForGlob( globSample4 );
    test.identical( got.source, expected4.source );

    test.description = 'complex pattern';
    var got = _.regexpForGlob( globSample5 );
    test.identical( got.source, expected5.source );


    if( Config.debug )
    {

      test.description = 'missing arguments';
      test.shouldThrowError( function()
      {
        _.regexpForGlob();
      });

      test.description = 'argument is not string';
      test.shouldThrowError( function()
      {
        _.regexpForGlob( {} );
      });
    }
  };

//

  var regexpMakeArray = function( test )
  {
    var arrOfStr = [ 'hello', 'world' ],
      singleStr = 'hello',
      singleReg = /world/,
      wrongParam1 = null,
      wrongParam2 = [ 3, 4 ],
      expectedArr1 = [ /hello/, /world/ ],
      expectedArr2 = [ /hello/ ],
      expectedArr3 = [ singleReg ];

    var getSource = function( v )
    {
      return v.source;
    }

    test.description = 'argument is array of string';
    var got = _.regexpMakeArray( arrOfStr );
    test.identical( got.map( getSource ), expectedArr1.map( getSource ) );

    test.description = 'argument is array of regexp';
    var got = _.regexpMakeArray( ArrOfRegx1 );
    test.identical( got, ArrOfRegx1 );

    test.description = 'argument is single string';
    var got = _.regexpMakeArray( singleStr );
    test.identical( got.map( getSource ), expectedArr2.map( getSource ) );

    test.description = 'argument is single regexp';
    var got = _.regexpMakeArray( singleReg );
    test.identical( got, expectedArr3 );

    test.description = 'argument is empty arr';
    var got = _.regexpMakeArray( [] );
    test.identical( got, [] );

    if( Config.debug )
    {
      test.description = 'call without arguments';
      test.shouldThrowError( function()
      {
        _.regexpMakeArray();
      });

      test.description = 'call with wrong type argument';
      test.shouldThrowError( function()
      {
        _.regexpMakeArray( wrongParam1 );
      });

      test.description = 'call with wrong type argument';
      test.shouldThrowError( function()
      {
        _.regexpMakeArray( wrongParam2 );
      });
    }
  };

//

  var regexpMakeExpression = function( test )
  {
    var simpleStr = 'hello',
      simpleReg = /world/,
      strWithSpChar = 'Hello. How are you?',
      wrongParam1 = null,
      expected1 = /hello/,
      expected2 = /Hello\. How are you\?/;


    test.description = 'argument is simple string';
    var got = _.regexpMakeExpression( simpleStr );
    test.identical( got.source, expected1.source );

    test.description = 'argument is regexp';
    var got = _.regexpMakeExpression( simpleReg );
    test.identical( got, simpleReg );

    test.description = 'argument is string with special characters';
    var got = _.regexpMakeExpression( strWithSpChar );
    test.identical( got.source, expected2.source );

    if( Config.debug )
    {
      test.description = 'call without arguments';
      test.shouldThrowError( function()
      {
        _.regexpMakeExpression();
      });

      test.description = 'call with wrong type argument';
      test.shouldThrowError( function()
      {
        _.regexpMakeExpression( wrongParam1 );
      });
    }
  };

//

  var _regexpAny = function( test )
  {
    var strForTest1 = 'some text 5',
      wrongTypeArr = [ /a/, /b/, '5' ],
      expectedIndex = 2,
      defaultParam = true;

    test.description = 'regexp is found in str';
    var got = _._regexpAny( ArrOfRegx2, strForTest1, false );
    test.identical( got, expectedIndex );

    test.description = 'regexp isn\'t found in str';
    var got = _._regexpAny( ArrOfRegx3, strForTest1, false );
    test.identical( got, false );

    test.description = 'empty regexp array passed';
    var got = _._regexpAny( [], strForTest1, defaultParam );
    test.identical( got, defaultParam );

    if( Config.debug )
    {
      test.description = 'missed all arguments';
      test.shouldThrowError( function()
      {
        _._regexpAny()
      });

      test.description = 'missed one of arguments';
      test.shouldThrowError( function()
      {
        _._regexpAny( ArrOfRegx2, strForTest1 )
      });

      test.description = 'first argument is not array';
      test.shouldThrowError( function()
      {
        _._regexpAny( 'hello', strForTest1, false );
      });

      test.description = 'element of array is not regexp';
      test.shouldThrowError( function()
      {
        _._regexpAny( wrongTypeArr, strForTest1, false );
      });
    }
  };

//

  var _regexpAll = function( test )
  {
    var strForTest1 = '012349',
      wrongTypeArr = [ /0/, /3/, '9' ],
      expectedIndex = 2,
      defaultParam = false;

    test.description = 'all regexp is found in str';
    var got = _._regexpAll( ArrOfRegx1, strForTest1, false );
    test.identical( got, true );

    test.description = 'one of regexp isn\'t found in str';
    var got = _._regexpAll( ArrOfRegx2, strForTest1, false );
    test.identical( got, expectedIndex );

    test.description = 'empty regexp array passed';
    var got = _._regexpAll( [], strForTest1, defaultParam );
    test.identical( got, defaultParam );

    if( Config.debug )
    {
      test.description = 'missed all arguments';
      test.shouldThrowError( function()
      {
        _._regexpAll()
      });

      test.description = 'missed one of arguments';
      test.shouldThrowError( function()
      {
        _._regexpAll( ArrOfRegx2, strForTest1 )
      });

      test.description = 'first argument is not array';
      test.shouldThrowError( function()
      {
        _._regexpAll( 'hello', strForTest1, false );
      });

      test.description = 'element of array is not regexp';
      test.shouldThrowError( function()
      {
        _._regexpAll( wrongTypeArr, strForTest1, false );
      });
    }
  };

//

  var regexpTest = function( test )
  {
    var regexpObj1 =
      {
        includeAny: [ /2/, /6/, /7/ ],
        includeAll: [ /0/, /1/, /2/ ],
        excludeAny: [ /6/, /7/, /8/ ],
        excludeAll: [ /2/, /6/, /7/ ]
      },
      regexpObj2 =
      {
        includeAny: [ /9/, /6/, /7/ ], //
        includeAll: [ /0/, /1/, /2/ ],
        excludeAny: [ /6/, /7/, /8/ ],
        excludeAll: [ /2/, /6/, /7/ ]
      },
      regexpObj3 =
      {
        includeAny: [ /2/, /6/, /7/ ],
        includeAll: [ /0/, /6/, /2/ ], //
        excludeAny: [ /6/, /7/, /8/ ],
        excludeAll: [ /2/, /6/, /7/ ]
      },
      regexpObj4 =
      {
        includeAny: [ /2/, /6/, /7/ ],
        includeAll: [ /0/, /1/, /2/ ],
        excludeAny: [ /6/, /7/, /0/ ], //
        excludeAll: [ /2/, /6/, /7/ ]
      },
      regexpObj5 =
      {
        includeAny: [ /2/, /6/, /7/ ],
        includeAll: [ /0/, /1/, /2/ ],
        excludeAny: [ /6/, /7/, /8/ ],
        excludeAll: [ /0/, /1/, /2/ ] //
      },
      testStr = '012345';

    test.description = 'all regeps array are matched';
    var got = _.regexpTest( regexpObj1, testStr );
    test.identical( got, true );

    test.description = 'includeAny parameter do not contain any regexp that matches the string';
    var got = _.regexpTest( regexpObj2, testStr );
    test.identical( got, false );

    test.description = 'includeAll contain any regexp that do not matches the string';
    var got = _.regexpTest( regexpObj3, testStr );
    test.identical( got, false );

    test.description = 'excludeAny contain any regexp that matches the test string';
    var got = _.regexpTest( regexpObj4, testStr );
    test.identical( got, false );

    test.description = 'excludeAll contain regexps that all matches the test string';
    var got = _.regexpTest( regexpObj4, testStr );
    test.identical( got, false );

    /**/

    if( Config.debug )
    {

      test.description = 'missing arguments';
      test.shouldThrowError( function()
      {
        _.regexpTest();
      });

      test.description = 'missing string for testing';
      test.shouldThrowError( function()
      {
        _.regexpTest( regexpObj1 );
      });

      test.description = 'regexpObject is not a map object';
      test.shouldThrowError( function()
      {
        _.regexpTest( null, testStr );
      });

      test.description = 'second argument is not a string';
      test.shouldThrowError( function()
      {
        _.regexpTest( regexpObj1, 44 );
      });

    }
  };

//

  var _regexpObjectExtend = function( test )
  {
    var src1 =
        [
          {
            includeAny: ArrOfRegx1,
            includeAll: ArrOfRegx2,
            excludeAny: ArrOfRegx3,
            excludeAll: ArrOfRegx4
          }
        ],
      src2 =
        [
          {
            includeAny: ArrOfRegx1,
            includeAll: ArrOfRegx2,
            excludeAny: ArrOfRegx3,
            excludeAll: ArrOfRegx4
          },
          {
            includeAny: ArrOfRegx5,
            includeAll: ArrOfRegx6,
            excludeAny: ArrOfRegx7,
            excludeAll: ArrOfRegx8
          }
        ],

      wrongSrc1 =
      {
        includeAny: ArrOfRegx5,
        includeAll: ArrOfRegx6,
        excludeAny: ArrOfRegx7,
        excludeAll: ArrOfRegx8
      },
      wrongSrc2 = [ 'includeAny' ],
      wrongSrc3 =
        [
          {
            includeAny: ArrOfRegx5,
            includeAll: ArrOfRegx6,
            excludeAny: ArrOfRegx7,
            excludeAll: ArrOfRegx8,
            excludeSome: [ /[^a]/ ]
          }
        ],

      dst1 = {},
      dst2 =
      {
        includeAny: [ /a0/, /a1/, /a2/ ],
        includeAll: [ /b0/, /c1/, /c2/ ],
        excludeAny: [ /c0/, /c1/, /c2/ ],
        excludeAll: [ /d0/, /d1/, /d2/ ]
      },
      dst3 =
      {
        includeAny: [ /a0/, /a1/, /a2/ ],
        includeAll: [ /b0/, /c1/, /c2/ ],
        excludeAny: [ /c0/, /c1/, /c2/ ],
        excludeAll: [ /d0/, /d1/, /d2/ ]
      },

      expected1 = src1.slice().pop(),
      expected2 =
      {
        includeAny: src2[ 1 ].includeAny,
        includeAll: dst2.includeAll.concat( src2[ 0 ].includeAll, src2[ 1 ].includeAll ),
        excludeAny: dst2.excludeAny.concat( src2[ 0 ].excludeAny, src2[ 1 ].excludeAny ),
        excludeAll: src2[ 1 ].excludeAll
      },
      expected3 =
      {
        includeAny: dst3.includeAny.concat( src2[ 0 ].includeAny, src2[ 1 ].includeAny ),
        includeAll: dst3.includeAll.concat( src2[ 0 ].includeAll, src2[ 1 ].includeAll ),
        excludeAny: dst3.excludeAny.concat( src2[ 0 ].excludeAny, src2[ 1 ].excludeAny ),
        excludeAll: dst3.excludeAll.concat( src2[ 0 ].excludeAll, src2[ 1 ].excludeAll )
      },

      extendOpt1 =
      {
        dst: dst1,
        srcs: src1,
        shrinking: true
      },
      extendOpt2 =
      {
        dst: dst2,
        srcs: src2,
        shrinking: true
      },
      extendOpt3 =
      {
        dst: dst3,
        srcs: src2,
        shrinking: false
      },

      wrongOpt1 =
      {
        dst: dst1,
        srcs: src1,
      },
      wrongOpt2 =
      {
        dst: null,
        srcs: src1,
        shrinking: false
      },
      wrongOpt3 =
      {
        dst: dst3,
        srcs: wrongSrc1,
        shrinking: false
      },
      wrongOpt4 =
      {
        dst: {},
        srcs: wrongSrc2,
        shrinking: false
      },
      wrongOpt5 =
      {
        dst: {},
        srcs: wrongSrc3,
        shrinking: false
      };

    test.description = 'simple rejexps objects extend with shrinking';
    var got = _._regexpObjectExtend( extendOpt1 );
    test.identical( got, expected1 );

    test.description = 'rejexps objects extend with shrinking';
    var got = _._regexpObjectExtend( extendOpt2 );
    test.identical( got, expected2 );

    test.description = 'rejexps objects extend without shrinking';
    var got = _._regexpObjectExtend( extendOpt3 );
    test.identical( got, expected3 );

    /**/

    if( Config.debug )
    {

      test.description = 'missing parameters in options argument';
      test.shouldThrowError( function()
      {
        _._regexpObjectExtend( wrongOpt1 );
      });

      test.description = 'options.dist is not object';
      test.shouldThrowError( function()
      {
        _._regexpObjectExtend( wrongOpt2 );
      });

      test.description = 'options.srcs not wrapped into array';
      test.shouldThrowError( function()
      {
        _._regexpObjectExtend( wrongOpt3 );
      });

      test.description = 'element of options.srcs is not object';
      test.shouldThrowError( function()
      {
        _._regexpObjectExtend( wrongOpt4 );
      });

      test.description = 'element of options.srcs has wrong format: (extra property)';
      test.shouldThrowError( function()
      {
        _._regexpObjectExtend( wrongOpt5 );
      });
    }

  }

//

  var regexpObjectBroaden = function( test )
  {
    var dst1 = {},
      dst2 =
      {
        includeAny: [ /a0/, /a1/, /a2/ ],
        includeAll: [ /b0/, /c1/, /c2/ ],
        excludeAny: [ /c0/, /c1/, /c2/ ],
        excludeAll: [ /d0/, /d1/, /d2/ ]
      },


      expected0 =
      {
        includeAny: [],
        includeAll: [],
        excludeAny: [],
        excludeAll: []
      },
      expected1 = src1,
      expected2 =
      {
        includeAny: dst2.includeAny.concat( src1.includeAny, src2.includeAny, src3.includeAny ),
        includeAll: dst2.includeAll.concat( src1.includeAll, src2.includeAll, src3.includeAll ),
        excludeAny: dst2.excludeAny.concat( src1.excludeAny, src2.excludeAny, src3.excludeAny ),
        excludeAll: dst2.excludeAll.concat( src1.excludeAll, src2.excludeAll, src3.excludeAll )
      };

    test.description = 'empty RegexpObject object broaden nothing (missed source for RegexpObject extend)';
    var got = _.regexpObjectBroaden( {} );
    test.identical( got, expected0 );

    test.description = 'empty RegexpObject object broaden by single object';
    var got = _.regexpObjectBroaden( dst1, src1 );
    test.identical( got, expected1 );

    test.description = 'RegexpObjec with existing data broaden by other RegexpObject objects';
    var got = _.regexpObjectBroaden( dst2, src1, src2, src3 );
    test.identical( got, expected2 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.regexpObjectBroaden();
      });

      test.description = 'result (first passed) parameter in not object';
      test.shouldThrowError( function()
      {
        _.regexpObjectBroaden( 'hello', src1 );
      });

      test.description = 'source for RegexpObject extend has extra parameter';
      test.shouldThrowError( function()
      {
        _.regexpObjectBroaden( {}, wrongSrc );
      });
    }
  };

  //

  var regexpObjectShrink = function( test )
  {
    var dst1 = {},
      dst2 =
      {
        includeAny: [ /a0/, /a1/, /a2/ ],
        includeAll: [ /b0/, /c1/, /c2/ ],
        excludeAny: [ /c0/, /c1/, /c2/ ],
        excludeAll: [ /d0/, /d1/, /d2/ ]
      },


      expected0 =
      {
        includeAny: [],
        includeAll: [],
        excludeAny: [],
        excludeAll: []
      },
      expected1 = src1,
      expected2 =
      {
        includeAny: src3.includeAny,
        includeAll: dst2.includeAll.concat( src1.includeAll, src2.includeAll, src3.includeAll ),
        excludeAny: dst2.excludeAny.concat( src1.excludeAny, src2.excludeAny, src3.excludeAny ),
        excludeAll: src3.excludeAll
      };

    test.description = 'empty RegexpObject object broaden nothing (missed source for RegexpObject extend)';
    var got = _.regexpObjectShrink( {} );
    test.identical( got, expected0 );

    test.description = 'empty RegexpObject object broaden by single object';
    var got = _.regexpObjectShrink( dst1, src1 );
    test.identical( got, expected1 );

    test.description = 'RegexpObjec with existing data broaden by other RegexpObject objects';
    var got = _.regexpObjectShrink( dst2, src1, src2, src3 );
    test.identical( got, expected2 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.regexpObjectShrink();
      });

      test.description = 'result (first passed) parameter in not object';
      test.shouldThrowError( function()
      {
        _.regexpObjectShrink( 'hello', src1 );
      });

      test.description = 'source for RegexpObject extend has extra parameter';
      test.shouldThrowError( function()
      {
        _.regexpObjectShrink( {}, wrongSrc );
      });
    }
  };

  var regexpObjectMake = function( test )
  {
    var src1 = {},
      src2 = [],

      src3 =
      {
        includeAny: [ /a0/, /a1/, /a2/ ],
        includeAll: [ /b0/, /c1/, /c2/ ],
        excludeAny: [ /c0/, /c1/, /c2/ ],
        excludeAll: [ /d0/, /d1/, /d2/ ]
      },

      src4 =
      {
        includeAny: [ 'a0', 'a1', 'a2' ],
        includeAll: [ 'b0', 'c1', 'c2' ],
        excludeAny: [ 'c0', 'c1', 'c2' ],
        excludeAll: [ 'd0', 'd1', 'd2' ]
      },

      src5 = [ 'c0', 'c1', 'c2' ],

      src6 = 'hello',
      src7 = /world/,

      src8 =
      [
        {
          includeAny: ArrOfRegx1,
          includeAll: ArrOfRegx2,
          excludeAny: ArrOfRegx3,
          excludeAll: ArrOfRegx4
        },
        {
          includeAny: ArrOfRegx5,
          includeAll: ArrOfRegx6,
          excludeAny: ArrOfRegx7,
          excludeAll: ArrOfRegx8
        }
      ],

      src9 = [
        'cf0',
        'cf1',
        'cf2',
        /world/,
        {
          includeAny: [ 'a0', 'a1', 'a2' ],
          includeAll: [ 'b0', 'c1', 'c2' ],
          excludeAny: [ 'c0', 'c1', 'c2' ],
          excludeAll: [ 'd0', 'd1', 'd2' ]
        },
        {
          includeAny: ArrOfRegx5,
          includeAll: ArrOfRegx6,
          excludeAny: ArrOfRegx7,
          excludeAll: ArrOfRegx8
        }
      ],

      wrongSrc1 =
      {
        includeAny: [ /a0/, /a1/, /a2/ ],
        includeAll: [ /b0/, null, /c2/ ],
        excludeAny: [ /c0/, /c1/, /c2/ ],
        excludeAll: [ /d0/, /d1/, /d2/ ]
      },
      wrongSrc2 = [ 'c0', 'c1', 44 ],
      wrongDefaultMode = 'includeSome',

      expected4 =
      {
        includeAny: [ /a0/, /a1/, /a2/ ],
        includeAll: [ /b0/, /c1/, /c2/ ],
        excludeAny: [ /c0/, /c1/, /c2/ ],
        excludeAll: [ /d0/, /d1/, /d2/ ]
      },
      expected5 =
      {
        excludeAny: [ /c0/, /c1/, /c2/ ]
      },
      expected6 =
      {
        includeAny: [ /hello/ ]
      },
      expected7 =
      {
        includeAll: [ /world/ ]
      },

      expected8 =
      {
        includeAny: src8[1].includeAny,
        includeAll: src8[0].includeAll.concat( src8[1].includeAll ),
        excludeAny: src8[0].excludeAny.concat( src8[1].excludeAny ),
        excludeAll: src8[1].excludeAll
      },
      expected9 =
      {
        includeAny: ArrOfRegx5,
        includeAll: [ /b0/, /c1/, /c2/, /14/, /16/, /17/, /cf0/, /cf1/, /cf2/, /world/],
        excludeAny: [ /c0/, /c1/, /c2/, /18/, /19/, /20/ ],
        excludeAll: ArrOfRegx8
      };



    getSourceFromMap(expected4);
    getSourceFromMap(expected5);
    getSourceFromMap(expected6);
    getSourceFromMap(expected7);
    getSourceFromMap(expected9);

    test.description = 'argument is an empty object';
    var got = _.regexpObjectMake(src1);
    test.identical( got, {} );

    test.description = 'as argument passed RegexpObject object';
    var got = _.regexpObjectMake(src3);
    test.identical( got, src3 );

    test.description = 'as argument passed map of arrays object';
    var got = _.regexpObjectMake(src4);
    getSourceFromMap( got );
    test.identical( got, expected4 );

    test.description = 'as argument passed array of strings object';
    var got = _.regexpObjectMake(src5, 'excludeAny');
    getSourceFromMap( got );
    test.identical( got, expected5 );

    test.description = 'as argument passed RegexpObject object';
    var got = _.regexpObjectMake(src6, 'includeAny');
    getSourceFromMap( got );
    test.identical( got, expected6 );

    test.description = 'as argument passed RegexpObject object';
    var got = _.regexpObjectMake(src7, 'includeAll');
    getSourceFromMap( got );
    test.identical( got, expected7 );

    test.description = 'as argument passed an array of RegexpObject object';
    var got = _.regexpObjectMake(src8, 'excludeAll');
    test.identical( got, expected8 );

    test.description = 'as argument passed an array of mixed type object';
    var got = _.regexpObjectMake(src9, 'includeAll');
    getSourceFromMap( got );
    test.identical( got, expected9 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.regexpObjectMake();
      });

      test.description = 'passed array as source without defaultMode argument';
      test.shouldThrowError( function()
      {
        _.regexpObjectMake(src2);
      });

      test.description = 'passed string as source without defaultMode argument';
      test.shouldThrowError( function()
      {
        _.regexpObjectMake(src6);
      });

      test.description = 'passed regexp as source without defaultMode argument';
      test.shouldThrowError( function()
      {
        _.regexpObjectMake(src7);
      });

      test.description = 'passed unexpected argument type argument';
      test.shouldThrowError( function()
      {
        _.regexpObjectMake(44, 'includeAll');
      });

      test.description = 'passed object that contain unexpected type';
      test.shouldThrowError( function()
      {
        _.regexpObjectMake(wrongSrc1);
      });

      test.description = 'passed array that contain unexpected type';
      test.shouldThrowError( function()
      {
        _.regexpObjectMake(wrongSrc2, 'includeAll');
      });

      test.description = 'passed unexpected defaultMode argument';
      test.shouldThrowError( function()
      {
        _.regexpObjectMake(src5, wrongDefaultMode);
      });
    }
  };

  //

  var regexpObjectBut = function( test )
  {
    var src5 =
      {
        includeAny: ArrOfRegx1,
        includeAll: ArrOfRegx2,
        excludeAny: ArrOfRegx3,
        excludeAll: ArrOfRegx4
      },
      src6 =
      {
        includeAny: ArrOfRegx6,
        excludeAny: ArrOfRegx7,
      },
      expected1 =
      {
        includeAny: []
      },
      expected2 =
      {
        includeAny: ArrOfRegx3,
        includeAll: ArrOfRegx4,
        excludeAny: ArrOfRegx1,
        excludeAll: ArrOfRegx2
      },
      expected3 =
      {
        includeAny: ArrOfRegx3.concat(ArrOfRegx7),
        includeAll: ArrOfRegx4,
        excludeAny: ArrOfRegx1.concat(ArrOfRegx6),
        excludeAll: ArrOfRegx2
      };
    test.description = 'arguments are missing';
    var got = _.regexpObjectBut();
    test.identical( got, expected1 );

    test.description = 'argument is single RegexpObject map';
    var got = _.regexpObjectBut( src1 );
    test.identical( got, expected2 );

    test.description = 'arguments are several RegexpObject maps';
    var got = _.regexpObjectBut( src5, src6 );
    test.identical( got, expected3 );

    if( Config.debug )
    {
      test.description = 'passed incompatibility arguments';
      test.shouldThrowError( function()
      {
        _.regexpObjectBut(src2, src3);
      });
    }
  };

  //

  var regexpObjectOrering = function( test )
  {
    var  arrOfStr0 = [],
      arrOfStr1 = [ '0', '1', '2' ],
      arrOfStr2 = [ '3', '4', '5' ],
      arrOfStr3 = ['0', '1'],
      arrOfStr4 = ['3', '', '4'],
      expected0 = [],
      expected1 =
      [
        { includeAll: [ /0/ ] },
        { includeAll: [ /1/ ] },
        { includeAll: [ /2/ ] }
      ],
      e1 = expected1.length,
      expected2 =
      [
        { includeAny: [], includeAll: [ /0/, /3/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /0/, /4/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /0/, /5/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /1/, /3/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /1/, /4/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /1/, /5/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /2/, /3/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /2/, /4/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /2/, /5/ ], excludeAny: [], excludeAll: [] }
      ],
      e2 = expected2.length,
      expected3 =
      [
        { includeAny: [], includeAll: [ /0/, /3/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /0/], excludeAny: [/3/, /4/], excludeAll: [] },
        { includeAny: [], includeAll: [ /0/, /4/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /1/, /3/ ], excludeAny: [], excludeAll: [] },
        { includeAny: [], includeAll: [ /1/ ], excludeAny: [/3/, /4/], excludeAll: [] },
        { includeAny: [], includeAll: [ /1/, /4/ ], excludeAny: [], excludeAll: [] }
      ],
      e3 = expected3.length;

    while( e1-- )
    getSourceFromMap(expected1[ e1 ]);

    while( e2-- )
    getSourceFromMap(expected2[ e2 ]);

    while( e3-- )
    getSourceFromMap(expected3[ e3 ]);

    test.description = 'passed empty array as argument';
    var got = _.regexpObjectOrering(arrOfStr0);
    test.identical( got, expected0 );

    test.description = 'passed array of strings without empty strings';
    var got = _.regexpObjectOrering(arrOfStr1),
      gl = got.length;
    while( gl-- )
    getSourceFromMap(got[ gl ]);
    test.identical( got, expected1 );

    test.description = 'passed multiple array of strings without empty strings';
    var got = _.regexpObjectOrering(arrOfStr1, arrOfStr2),
      gl = got.length;
    while( gl-- )
      getSourceFromMap(got[ gl ]);
    test.identical( got, expected2 );

    test.description = 'passed multiple arrays with empty strings';
    var got = _.regexpObjectOrering(arrOfStr3, arrOfStr4),
      gl = got.length;
    while( gl-- )
    getSourceFromMap(got[ gl ]);
    test.identical( got, expected3 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _.regexpObjectOrering();
      } );

      test.description = 'passed non array/string parameter';
      test.shouldThrowError( function()
      {
        _.regexpObjectOrering(4, arrOfStr1);
      } );
    }
  };

  //

  var regexpArrayIndex = function( test )
  {
    var str1 = 'some text 012',
      str2 = '056',
      notArray = null,
      notStr = 12,
      notRegexp = [1, 2],
      expected1 = 0,
      expected2 = 0,
      expected3 = 2,
      expected4 = -1;


    test.description = 'all regexps match in string';
    var got = _.regexpArrayIndex( ArrOfRegx1, str1 );
    test.identical( got, expected1 );

    test.description = 'first regexps matches in string';
    var got = _.regexpArrayIndex( ArrOfRegx1, str2 );
    test.identical( got, expected2 );

    test.description = 'third regexps matches in string';
    var got = _.regexpArrayIndex( ArrOfRegx2, str2 );
    test.identical( got, expected3 );

    test.description = 'no one of the regexps do not match in string';
    var got = _.regexpArrayIndex( ArrOfRegx3, str1 );
    test.identical( got, expected4 );

    if( Config.debug )
    {
      test.description = 'missing arguments';
      test.shouldThrowError( function()
      {
        _.regexpArrayIndex();
      });

      test.description = 'first parameter is not array';
      test.shouldThrowError( function()
      {
        _.regexpArrayIndex(notArray, str1);
      });

      test.description = 'second parameter is not string';
      test.shouldThrowError( function()
      {
        _.regexpArrayIndex(ArrOfRegx1, notStr);
      });

      test.description = 'element of array is not RegExp';
      test.shouldThrowError( function()
      {
        _.regexpArrayIndex(notRegexp, str1);
      });
    }

  };

  //

  var _regexpObjectOrderingExclusion = function( test )
  {
    var arrOfStr1 = [ '0', '1', '2' ],
      arrOfStr2 = [ '0', '1', '', '2', '' ],
      expected0 = [],
      expected1 =
      [
        { includeAll: [ /0/ ] },
        { includeAll: [ /1/ ] },
        { includeAll: [ /2/ ] },
      ],
      e1 = expected1.length,
      expected2 =
      [
        { includeAll: [ /0/ ] },
        { includeAll: [ /1/ ] },
        { includeAll: [], includeAny: [], excludeAll: [], excludeAny: [ /0/, /1/, /2/ ] },
        { includeAll: [ /2/ ] },
        { includeAll: [], includeAny: [], excludeAll: [], excludeAny: [ /0/, /1/, /2/ ] }
      ],
      e2 = expected2.length;

    while( e1-- )
    getSourceFromMap(expected1[ e1 ]);

    while( e2-- )
    getSourceFromMap(expected2[ e2 ]);

    test.description = 'passed some falsy value as parameter';
    var got = _._regexpObjectOrderingExclusion(null);
    test.identical( got, expected0 );

    test.description = 'passed array of strings without empty strings';
    var got = _._regexpObjectOrderingExclusion(arrOfStr1),
      gl = got.length;
    while( gl-- )
    getSourceFromMap(got[ gl ]);
    test.identical( got, expected1 );

    test.description = 'passed array of strings without empty strings';
    var got = _._regexpObjectOrderingExclusion(arrOfStr2),
      gl = got.length;
    while( gl-- )
    getSourceFromMap(got[ gl ]);
    test.identical( got, expected2 );

    if( Config.debug )
    {
      test.description = 'missed arguments';
      test.shouldThrowError( function()
      {
        _._regexpObjectOrderingExclusion();
      } );

      test.description = 'passed more that 1 argument';
      test.shouldThrowError( function()
      {
        _._regexpObjectOrderingExclusion(arrOfStr1, arrOfStr1);
      } );
    }
  };

  //

  var Proto =
  {

    name: 'regexp',

    tests:
    {

      regexpEscape        : regexpEscape,
      regexpForGlob       : regexpForGlob,
      regexpMakeArray     : regexpMakeArray,
      regexpMakeExpression: regexpMakeExpression,
      _regexpAny          : _regexpAny,
      _regexpAll          : _regexpAll,
      regexpTest          : regexpTest,
      _regexpObjectExtend : _regexpObjectExtend,
      regexpObjectBroaden : regexpObjectBroaden,
      regexpObjectShrink  : regexpObjectShrink,
      regexpObjectMake    : regexpObjectMake,
      regexpObjectBut     : regexpObjectBut,
      regexpObjectOrering : regexpObjectOrering,
      regexpArrayIndex    : regexpArrayIndex,
      _regexpObjectOrderingExclusion: _regexpObjectOrderingExclusion

    }

  }

  _.mapExtend( Self, Proto );

  if( typeof module !== 'undefined' && !module.parent )
  _.testing.test(Self);

} )( );
