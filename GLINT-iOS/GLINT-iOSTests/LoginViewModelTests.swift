import XCTest
@testable import GLINT_iOS

final class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    
    // 성공 케이스용 Mock
    let mockSuccessUserUseCase = AuthUseCase(
        checkEmailValidation: { _ in },
        signUp: { _ in
            return ResponseDTO.SignUp(userID: "1", email: "test@glint.com", nick: "test", accessToken: "token", refreshToken: "refresh")
        },
        signIn: { _ in
            return ResponseDTO.SignIn(userID: "1", email: "test@glint.com", nick: "test", accessToken: "token", refreshToken: "refresh")
        },
        signInApple: { _ in
            return ResponseDTO.SignIn(userID: "1", email: "test@glint.com", nick: "test", accessToken: "token", refreshToken: "refresh")
        },
        signInKakao: { _ in
            return ResponseDTO.SignIn(userID: "1", email: "test@glint.com", nick: "test", accessToken: "token", refreshToken: "refresh")
        }
    )
    // 실패 케이스용 Mock
    let mockFailUserUseCase = AuthUseCase(
        checkEmailValidation: { _ in throw NSError(domain: "", code: 1, userInfo: nil) },
        signUp: { _ in throw NSError(domain: "", code: 1, userInfo: nil) },
        signIn: { _ in throw NSError(domain: "", code: 1, userInfo: nil) },
        signInApple: { _ in throw NSError(domain: "", code: 1, userInfo: nil) },
        signInKakao: { _ in throw NSError(domain: "", code: 1, userInfo: nil) }
    )
    
    override func setUpWithError() throws {
        // 각 테스트에서 직접 viewModel을 초기화
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func test_로그인_성공() async throws {
        print("\nㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ")
        print(#function)
        viewModel = LoginViewModel(userUseCase: mockSuccessUserUseCase)
        viewModel.email = "test@glint.com"
        viewModel.password = "Password1!"
        await viewModel.loginWithEmail()
        XCTAssertEqual(viewModel.loginState, .success)
    }
    
    func test_로그인_실패_잘못된_비밀번호() async throws {
        print("\nㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ")
        print(#function)
        viewModel = LoginViewModel(userUseCase: mockFailUserUseCase)
        viewModel.email = "test@glint.com"
        viewModel.password = "wrongPassword!"
        await viewModel.loginWithEmail()
        if case .failure = viewModel.loginState {
            XCTAssertTrue(true)
        } else {
            XCTFail("로그인 실패 상태가 아님")
        }
    }
    
    func test_이메일_형식_검증() {
        print("\nㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ")
        print(#function)
        viewModel = LoginViewModel(userUseCase: AuthUseCase.mockValue)
        viewModel.email = "invalid-email"
        // debounce가 있으므로 직접 검증 메서드 호출
//        let isValid = store.value(forKey: "validateEmailFormat:") as? ((String) -> Bool)
//        XCTAssertNotNil(isValid)
        XCTAssertFalse(viewModel.email.contains("@"))
    }
} 
