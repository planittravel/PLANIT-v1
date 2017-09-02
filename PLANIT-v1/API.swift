//  This file was automatically generated and should not be edited.

import Apollo

public struct AuthProviderSignupData: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(auth0: AUTH_PROVIDER_AUTH0? = nil) {
    graphQLMap = ["auth0": auth0]
  }
}

public struct AUTH_PROVIDER_AUTH0: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(idToken: String) {
    graphQLMap = ["idToken": idToken]
  }
}

public final class CreateUserMutation: GraphQLMutation {
  public static let operationDefinition =
    "mutation CreateUser($AuthProviderSignupData: AuthProviderSignupData!) {" +
    "  createUser(authProvider: $AuthProviderSignupData) {" +
    "    __typename" +
    "    auth0UserId" +
    "  }" +
    "}"

  public let authProviderSignupData: AuthProviderSignupData

  public init(authProviderSignupData: AuthProviderSignupData) {
    self.authProviderSignupData = authProviderSignupData
  }

  public var variables: GraphQLMap? {
    return ["AuthProviderSignupData": authProviderSignupData]
  }

  public struct Data: GraphQLMappable {
    public let createUser: CreateUser?

    public init(reader: GraphQLResultReader) throws {
      createUser = try reader.optionalValue(for: Field(responseName: "createUser", arguments: ["authProvider": reader.variables["AuthProviderSignupData"]]))
    }

    public struct CreateUser: GraphQLMappable {
      public let __typename: String
      public let auth0UserId: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        auth0UserId = try reader.optionalValue(for: Field(responseName: "auth0UserId"))
      }
    }
  }
}