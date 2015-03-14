git = require('../../lib/workers/gh_client')
gh = require('../../lib/workers/gh')
users = require('../../lib/api/users')
teams = require('../../lib/api/teams')
auth = require('../../lib/validation/validation').auth
Promise = require('promise')

describe 'add_user', () ->
  beforeEach () ->
    this.user =
      rsrcs:
        gh:
          username: 'user1'
    this.team =
      rsrcs:
        gh:
          data:
            push: 1
            admin: 2

  it 'adds a user to the github team corresponding to the users role, and resolves empty', (done) ->
    spyOn(auth, '_has_resource_role').andReturn(true)
    spyOn(git.team.user, 'add').andReturn(Promise.resolve('xxx'))
    gh.testing.add_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.add).toHaveBeenCalledWith(2, 'user1')
      expect(resp).toBeUndefined()
      done()
    )

  it 'adds an employee to the admin team', (done) ->
    this.user.data = {contractor: false}

    spyOn(auth, '_has_resource_role').andReturn(true)
    spyOn(git.team.user, 'add').andReturn(Promise.resolve('xxx'))
    gh.testing.add_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.add).toHaveBeenCalledWith(2, 'user1')
      done()
    )

  it 'adds a contractor to the push team', (done) ->
    this.user.data = {contractor: true}

    spyOn(auth, '_has_resource_role').andReturn(true)
    spyOn(git.team.user, 'add').andReturn(Promise.resolve('xxx'))
    gh.testing.add_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.add).toHaveBeenCalledWith(1, 'user1')
      done()
    )

  it 'does nothing if the user does not have the github|user role', (done) ->
    spyOn(auth, '_has_resource_role').andReturn(false)
    spyOn(git.team.user, 'add').andReturn(Promise.resolve('xxx'))
    gh.testing.add_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.add).not.toHaveBeenCalled();
      done()
    )


describe 'remove_user', () ->
  beforeEach () ->
    this.user =
      name: '1234'
      rsrcs:
        gh:
          username: 'user1'
    this.team =
      roles:
        admin:
          members: []
        member:
          members: []
      rsrcs:
        gh:
          data:
            push: 1
            admin: 2

  it 'removes a user from the github team corresponding to the users role', (done) ->
    spyOn(auth, '_has_resource_role').andReturn(true)
    spyOn(git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    gh.testing.remove_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.remove).toHaveBeenCalledWith(2, 'user1')
      expect(resp).toBeUndefined()
      done()
    )

  it 'removes an employee from the admin team', (done) ->
    this.user.data = {contractor: false}

    spyOn(auth, '_has_resource_role').andReturn(true)
    spyOn(git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    gh.testing.remove_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.remove).toHaveBeenCalledWith(2, 'user1')
      done()
    )

  it 'removes a contractor from the push team', (done) ->
    this.user.data = {contractor: true}

    spyOn(auth, '_has_resource_role').andReturn(true)
    spyOn(git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    gh.testing.remove_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.remove).toHaveBeenCalledWith(1, 'user1')
      done()
    )

  it 'removes the user even if the user does not have the github|user role', (done) ->
    spyOn(auth, '_has_resource_role').andReturn(false)
    spyOn(git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    gh.testing.remove_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.remove).toHaveBeenCalled();
      done()
    )

  it 'does not remove the user if they have perms from another role in the same team', (done) ->
    this.team.roles.member.members.push('1234')
    spyOn(auth, '_has_resource_role').andReturn(true)
    spyOn(git.team.user, 'remove').andReturn(Promise.resolve('xxx'))
    gh.testing.remove_user(this.user, 'admin', this.team).then((resp) ->
      expect(git.team.user.remove).not.toHaveBeenCalled();
      done()
    )

describe 'remove_repo', () ->
  it 'removes a repo from all github teams corresponding to a given team', (done) ->
    team =
      rsrcs:
        gh:
          data:
            push: 1
            admin: 2
    spyOn(git.teams.repo, 'remove').andReturn(Promise.resolve('xxx'))
    gh.testing.remove_repo('a/b', team).then((resp) ->
      expect(git.teams.repo.remove).toHaveBeenCalledWith([1,2], 'a/b')
      expect(resp).toBeUndefined()
      done()
    )

describe 'create_team', () ->
  it 'creates github admin and push teams for the created kratos team; returns a {perm: team_id} hash', (done) ->
    create_team_resp = [{
        name: 'test team admin',
        id: 1355891,
        slug: 'test-team-admin',
        description: null,
        permission: 'admin',
      },
      { 
        name: 'test team write',
        id: 1355892,
        slug: 'test-team-write',
        description: null,
        permission: 'push',
      }]

    spyOn(git.teams, 'create').andReturn(Promise.resolve(create_team_resp))
    gh.testing.create_team('test').then((resp) ->
      expect(git.teams.create).toHaveBeenCalledWith([{name: 'test', permission: 'admin'}, {name: 'test', permission: 'push'}])
      expect(resp).toEqual({admin: 1355891, push: 1355892})
      done()
    )

describe 'handle_add_gh_rsrc_role', () ->
  handle_add_gh_rsrc_role = gh.handlers.user.self['r+']
  it 'adds the user to every github team corresponding to a kratos to which they belong', (done) ->
    team1 =
      rsrcs:
        gh:
          data:
            push: 11
            admin: 12
    team2 =
      rsrcs:
        gh:
          data:
            push: 21
            admin: 22
    team3 =
      rsrcs:
        gh:
          data:
            push: 31
            admin: 32
    user =
      name: '1234'
      rsrcs:
        gh:
          username: 'user1'
    spyOn(git.teams.user, 'add').andReturn(Promise.resolve('xxx'))
    spyOn(teams, 'pGetTeamRolesForUser').andReturn(
      Promise.resolve([{team: team1, role: 'member'}, {team: team2, role:'member'}])
    )
    handle_add_gh_rsrc_role({}, user).then((resp) ->
      expect(git.teams.user.add).toHaveBeenCalledWith([12,22], 'user1')
      expect(resp).toBeUndefined()
      done()
    )

describe 'handle_remove_gh_rsrc_role', () ->
  handle_remove_gh_rsrc_role = gh.handlers.user.self['r-']
  it 'removes the user from every github team corresponding to a kratos to which they belong', (done) ->
    team1 =
      rsrcs:
        gh:
          data:
            push: 11
            admin: 12
    team2 =
      rsrcs:
        gh:
          data:
            push: 21
            admin: 22
    team3 =
      rsrcs:
        gh:
          data:
            push: 31
            admin: 32
    user =
      name: '1234'
      rsrcs:
        gh:
          username: 'user1'
    spyOn(git.teams.user, 'remove').andReturn(Promise.resolve('xxx'))
    spyOn(teams, 'pGetTeamRolesForUser').andReturn(
      Promise.resolve([{team: team1, role: 'member'}, {team: team2, role:'member'}])
    )
    handle_remove_gh_rsrc_role({}, user).then((resp) ->
      expect(git.teams.user.remove).toHaveBeenCalledWith([12,22], 'user1')
      expect(resp).toBeUndefined()
      done()
    )

describe 'handle_deactivate_user', () ->
  beforeEach () ->
    spyOn(git.user, 'delete').andReturn(Promise.resolve('xxx'))
    this.user = {rsrcs: {}}
    this.handle_deactivate_user = gh.handlers.user['u-']

  it 'removes the user from the org', (done) ->
    this.user.rsrcs.gh = {username: 'user1'}
    this.handle_deactivate_user({}, this.user).then((resp) ->
      expect(git.user.delete).toHaveBeenCalledWith('user1')
      expect(resp).toBeUndefined()
      done()
    )

  it 'does nothing if the user does not have a github username', (done) ->
    this.handle_deactivate_user({}, this.user).then((resp) ->
      expect(git.user.delete).not.toHaveBeenCalled()
      expect(resp).toBeUndefined()
      done()
    )

describe 'add_asset', () ->
  beforeEach () ->
    spyOn(git.repo, 'createPush').andReturn(Promise.resolve({id: 456, name: 'test2', full_name: 'kratos-test/test2'}))
    spyOn(git.teams.repo, 'add').andReturn(Promise.resolve('xxx'))
    this.team =
      rsrcs:
        gh:
          assets: [
            id: "ab38f",
            gh_id: 123,
            name: "test1",
            full_name: "kratos-test/test1"
          ]
          data:
            push: 1
            admin: 2

  it 'does nothing if the repo already exists', (done) ->
    gh.add_asset('test1', this.team).then((resp) ->
      expect(git.repo.createPush).not.toHaveBeenCalled()
      expect(resp).toBeUndefined()
      done()
    )

  it "gets/creates a repo, adds to to the team's gh_teams, and returns the details to store in couch", (done) ->
    gh.add_asset('test2', this.team).then((resp) ->
      expect(git.repo.createPush).toHaveBeenCalledWith({name: 'test2'})
      expect(git.teams.repo.add).toHaveBeenCalledWith([1, 2], 'kratos-test/test2')
      expect(resp).toEqual({gh_id: 456, name: 'test2', full_name: 'kratos-test/test2'})
      done()
    )
