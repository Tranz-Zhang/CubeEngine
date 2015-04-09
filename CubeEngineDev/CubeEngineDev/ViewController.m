//
//  ViewController.m
//  CubeEngineDev
//
//  Created by chance on 15/3/5.
//  Copyright (c) 2015年 ByChance. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ViewController.h"
#import "CubeEngine.h"


GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

Byte gCubeIndicesData[36] = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35
};


//GLfloat gTriangleVertexData[108] =
//{
//    // Data layout for each line below is:
//    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
//
//    1.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
//    1.5f, -0.5f, 0.5f,       1.0f, 1.0f, 1.0f,
//    1.5f, -0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
//
//    1.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
//    0.5f, -0.5f, 0.5f,      -1.0f, 1.0f, 1.0f,
//    0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
//
//    1.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
//    1.5f, -0.5f, 0.5f,       1.0f, 1.0f, 1.0f,
//    0.5f, -0.5f, 0.5f,      -1.0f, 1.0f, 1.0f,
//
//    1.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
//    1.5f, -0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
//    0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
//
//    // bottom
//    0.5f, -0.5f, -0.5f,    0.0f, -1.0f, 0.0f,
//    1.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
//    0.5f, -0.5f, 0.5f,     0.0f, -1.0f, 0.0f,
//    0.5f, -0.5f, 0.5f,     0.0f, -1.0f, 0.0f,
//    1.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
//    1.5f, -0.5f, 0.5f,      0.0f, -1.0f, 0.0f,
//};

GLfloat gTriangleVertexData[108] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    
    0.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,       1.0f, 1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
    
    0.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,      -1.0f, 1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
    
    0.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,       1.0f, 1.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,      -1.0f, 1.0f, 1.0f,
    
    0.0f, 0.5f, 0.0f,       1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
    
    // bottom
    -0.5f, -0.5f, -0.5f,    0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,     0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,     0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,      0.0f, -1.0f, 0.0f,
};

GLfloat gArrowZVertexData[108] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    
    0.0f, 0.0f, 0.5f,       1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,       1.0f, 1.0f, 1.0f,
    -0.5f, 0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
    
    0.0f, 0.0f, 0.5f,       1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,      -1.0f, 1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
    
    0.0f, 0.0f, 0.5f,       1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       1.0f, 1.0f, 1.0f,
    0.5f, -0.5f, -0.5f,      -1.0f, 1.0f, 1.0f,
    
    0.0f, 0.0f, 0.5f,       1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
    
    // bottom
    0.5f, 0.5f, -0.5f,    0.0f, -1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,      0.0f, -1.0f, 0.0f,
};

GLfloat gArrowXVertexData[108] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    
    0.5f, 0.0f, 0.0f,       1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,       1.0f, 1.0f, 1.0f,
    -0.5f, 0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
    
    0.5f, 0.0f, 0.0f,       1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,      -1.0f, 1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
    
    0.5f, 0.0f, 0.0f,       1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,       1.0f, 1.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,      -1.0f, 1.0f, 1.0f,
    
    0.5f, 0.0f, 0.0f,       1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,      1.0f, 1.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,     -1.0f, 1.0f, -1.0f,
    
    // bottom
    -0.5f, 0.5f, 0.5f,    0.0f, -1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,     0.0f, -1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,     0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,     0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,      0.0f, -1.0f, 0.0f,
};

Byte gTriangleIndicesData[18] = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
};


@interface ViewController () {
    BOOL _isLookingAtObject;
    BOOL _isAttachingObject;
}
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *objectSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *operationSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *coordinateSegment;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (nonatomic, readonly) CEModel *testObject;
@property (nonatomic, readonly) CEModel_Deprecated *testObject2;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scene.camera.position = GLKVector3Make(0, 5, 5);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    NSData *vertexData = [NSData dataWithBytes:gArrowXVertexData length:sizeof(gArrowXVertexData)];
    NSData *indicesData = [NSData dataWithBytes:gTriangleIndicesData length:sizeof(gTriangleIndicesData)];
    CEMesh *mesh = [[CEMesh alloc] initWithVertexData:vertexData vertexDataType:CEVertexDataType_V
                                          indicesData:indicesData indicesDataType:CEIndicesDataType_UByte];
    _testObject = [[CEModel alloc] initWithMesh:mesh];
    _testObject.position = GLKVector3Make(1, 0, 0);
    //    _testObject.transformMatrix = GLKMatrix4Identity;
    
    [self.scene addModel:_testObject];
    
//    NSData *vertexData2 = [NSData dataWithBytes:gCubeVertexData length:sizeof(gCubeVertexData)];
//    _testObject2 = [CEModel_Deprecated modelWithVertexData:vertexData2 type:CEVertextDataType_V3N3];
//    [self.scene addRenderObject:_testObject2];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Cube Engine Dev: %@", CUBE_ENGINE_VERSION];
    _isLookingAtObject = NO;
    [self updateInfoView];
}


- (IBAction)onReset:(id)sender {
    self.testObject.position = GLKVector3Make(0, 0, 0);
    self.testObject.scale = GLKVector3Make(1, 1, 1);
    self.testObject.rotation = GLKQuaternionIdentity;
    self.testObject2.position = GLKVector3Make(0, 0, 0);
    self.testObject2.scale = GLKVector3Make(1, 1, 1);
    self.testObject2.rotation = GLKQuaternionIdentity;
    self.scene.camera.position = GLKVector3Make(0, 5, 5);
    self.scene.camera.scale = GLKVector3Make(1, 1, 1);
    self.scene.camera.rotation = GLKQuaternionIdentity;
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
    _objectSegment.selectedSegmentIndex = 0;
    _operationSegment.selectedSegmentIndex = 0;
    _coordinateSegment.selectedSegmentIndex = 0;
    _valueSlider.value = 0.5;
    
    [self updateInfoView];
}

- (void)updateInfoView {
    NSMutableString *infoString = [NSMutableString string];
    [infoString appendFormat:@"Object (%.2f, %.2f, %.2f)\n", self.testObject.position.x, self.testObject.position.y, self.testObject.position.z];
    [infoString appendFormat:@"Camera (%.2f, %.2f, %.2f)", self.scene.camera.position.x, self.scene.camera.position.y, self.scene.camera.position.z];
    self.infoTextView.text = infoString;
}

- (IBAction)onAttach:(UIButton *)button {
    _isAttachingObject = !_isAttachingObject;
    button.selected = _isAttachingObject;
    
    if (_isAttachingObject) {
        [self.testObject2 addChildObject:self.testObject];
        
    } else {
        [self.testObject removeFromParent];
    }
}

#pragma mark - Transform

- (IBAction)onSliderValueChange:(UISlider *)slider {
    switch (_operationSegment.selectedSegmentIndex) {
        case 0:
            [self testObjectLocationWithSlider:slider];
            break;
            
        case 1:
            [self testObjectRotationWithSlider:slider];
            break;
            
        case 2:
            [self testObjectScaleWithSlider:slider];
            break;
            
        default:
            break;
    }
    
    if (_isLookingAtObject) {
        [self.scene.camera lookAt:self.testObject.position];
    }
}

#pragma mark - Test Object Transfrom

- (CEObject *)currentObject {
    switch (_objectSegment.selectedSegmentIndex) {
        case 0:
            return self.testObject;
            
        case 1:
            return self.testObject2;
            
        case 2:
            return self.scene.camera;
            
        default:
            return nil;
    }
}

- (void)testObjectLocationWithSlider:(UISlider *)slider {
    CEObject *currentObject = [self currentObject];
    GLKVector3 location = currentObject.position;
    switch (_coordinateSegment.selectedSegmentIndex) {
        case 0:
            location.x = slider.value * 6 - 3;
            break;
            
        case 1:
            location.y = slider.value* 6 - 3;
            break;
            
        case 2:
            location.z = slider.value* 6 - 3;
            break;
            
        default:
            break;
    }
    currentObject.position = location;
}

- (void)testObjectRotationWithSlider:(UISlider *)slider {
    CEObject *currentObject = [self currentObject];
    GLKVector3 rotationAngles = currentObject.eulerAngles;
    switch (_coordinateSegment.selectedSegmentIndex) {
        case 0:
            rotationAngles.x = slider.value * 360 - 180;
            break;
            
        case 1:
            rotationAngles.y = slider.value * 360 - 180;
            break;
            
        case 2:
            rotationAngles.z = slider.value * 360 - 180;
            break;
            
        default:
            break;
    }
    
    currentObject.eulerAngles = rotationAngles;
}

- (void)testObjectScaleWithSlider:(UISlider *)slider {
    CEObject *currentObject = [self currentObject];
    GLKVector3 scale = currentObject.scale;
    switch (_coordinateSegment.selectedSegmentIndex) {
        case 0:
            scale.x = slider.value * 2;
            break;
            
        case 1:
            scale.y = slider.value * 2;
            break;
            
        case 2:
            scale.z = slider.value * 2;
            break;
            
        default:
            break;
    }
    
    currentObject.scale = scale;
}

- (IBAction)onSliderStop:(id)sender {
    [self updateInfoView];
}


#pragma mark - Test Move
static float lastSliderValue;
- (IBAction)onMovingObject:(UISlider *)slider {
    CEObject *object = [self currentObject];
    [object moveTowards:object.right withDistance:(slider.value - lastSliderValue)];
    lastSliderValue = slider.value;
}


- (IBAction)onEndMoving:(UISlider *)slider {
    [slider setValue:0 animated:YES];
    lastSliderValue = 0;
}


- (IBAction)onLookAt:(UIButton *)button {
    CEObject *currentObject = [self currentObject];
    [currentObject lookAt:self.testObject2.position];
}



@end


