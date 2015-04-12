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
#import "CEWireframe.h"


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

@property (nonatomic, readonly) CEModel *triangleObject;
@property (nonatomic, readonly) CEModel *cubeObject;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scene.camera.position = GLKVector3Make(0, 5, 5);
    [self.scene.camera lookAt:GLKVector3Make(0, 0, 0)];
    
//    NSData *triangleData = [NSData dataWithBytes:gCubeVertexData length:sizeof(gCubeVertexData)];
//    CEMesh *triangleMesh = [[CEMesh alloc] initWithVertexData:cubeData vertexDataType:CEVertexDataType_V_VN];
//    _triangleObject = [[CEModel alloc] initWithMesh:triangleMesh];
//    _triangleObject.position = GLKVector3Make(1, 0, 0);
//    [self.scene addModel:_triangleObject];
    
//    NSData *cubeData1 = [NSData dataWithBytes:gCubeVertexData length:sizeof(gCubeVertexData)];
//    CEMesh *cubeMesh1 = [[CEMesh alloc] initWithVertexData:cubeData1 vertexDataType:CEVertexDataType_V_VN];
//    CEModel *cubeObject = [[CEModel alloc] initWithMesh:cubeMesh1];
//    cubeObject.position = GLKVector3Make(1, 0, 0);
//    [self.scene addModel:cubeObject];
//    
//    NSData *triangleData = [NSData dataWithBytes:gArrowXVertexData length:sizeof(gArrowXVertexData)];
//    CEMesh *triangleMesh = [[CEMesh alloc] initWithVertexData:triangleData vertexDataType:CEVertexDataType_V_VN];
//    _triangleObject = [[CEModel alloc] initWithMesh:triangleMesh];
//    _triangleObject.position = GLKVector3Make(1, 0, 0);
//    [self.scene addModel:_triangleObject];
    
    NSData *cubeData = [NSData dataWithBytes:gCubeVertexData length:sizeof(gCubeVertexData)];
    CEMesh *cubeMesh = [[CEMesh alloc] initWithVertexData:cubeData vertexDataType:CEVertexDataType_V_VN];
    cubeMesh.showWireframe = YES;
    _cubeObject = [[CEModel alloc] initWithMesh:cubeMesh];
    _cubeObject.position = GLKVector3Make(-1, 0, 0);
    [self.scene addModel:_cubeObject];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Cube Engine Dev: %@", CUBE_ENGINE_VERSION];
    _isLookingAtObject = NO;
    [self updateInfoView];
}


- (IBAction)onReset:(id)sender {
    self.triangleObject.position = GLKVector3Make(0, 0, 0);
    self.triangleObject.scale = GLKVector3Make(1, 1, 1);
    self.triangleObject.rotation = GLKQuaternionIdentity;
    self.cubeObject.position = GLKVector3Make(0, 0, 0);
    self.cubeObject.scale = GLKVector3Make(1, 1, 1);
    self.cubeObject.rotation = GLKQuaternionIdentity;
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
    [infoString appendFormat:@"Object (%.2f, %.2f, %.2f)\n", self.triangleObject.position.x, self.triangleObject.position.y, self.triangleObject.position.z];
    [infoString appendFormat:@"Camera (%.2f, %.2f, %.2f)", self.scene.camera.position.x, self.scene.camera.position.y, self.scene.camera.position.z];
    self.infoTextView.text = infoString;
}

- (IBAction)onAttach:(UIButton *)button {
    _isAttachingObject = !_isAttachingObject;
    button.selected = _isAttachingObject;
    
    if (_isAttachingObject) {
        [self.cubeObject addChildObject:self.triangleObject];
        
    } else {
        [self.triangleObject removeFromParent];
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
        [self.scene.camera lookAt:self.triangleObject.position];
    }
}

#pragma mark - Test Object Transfrom

- (CEObject *)currentObject {
    switch (_objectSegment.selectedSegmentIndex) {
        case 0:
            return self.triangleObject;
            
        case 1:
            return self.cubeObject;
            
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
    [currentObject lookAt:self.cubeObject.position];
}



@end


